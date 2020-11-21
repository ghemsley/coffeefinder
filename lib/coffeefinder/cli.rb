require_relative './constants'
require_relative './business'
require 'optparse'
require 'tty-prompt'
require 'tty-table'
module Coffeefinder
  class CLI
    attr_accessor :geoip, :yelp
    attr_reader :options, :prompt, :limit, :radius, :ip_address, :sort_by, :strict

    def initialize
      self.options = {}
      create_option_parser
      self.limit = options[:limit] || 10
      self.radius = options[:radius] || 805.0
      self.ip_address = options[:ip_address] || ''
      self.sort_by = options[:sort_by] || 'best_match'
      self.strict = true
      self.prompt = TTY::Prompt.new
    end

    def create_option_parser
      OptionParser.new do |opts|
        opts.banner = <<~BANNER

                      ( (
                      ) )
                    ........
                    |      | ]
                    \\      /
                     `----'

          Usage: coffeefinder [options]

        BANNER
        opts.on('-r', '--radius MILES', 'How big of an area to search, in miles. Default: 0.5 miles, max 10 miles') do |radius|
          options[:radius] = [radius.to_f * 1609.34, 16_093.4].min
        end
        opts.on('-s', '--sort_by STRING', "How to sort results. Acceptable values: 'distance', 'rating', 'review_count', 'best_match'. Default: 'best_match'") do |sort_by|
          options[:sort_by] = sort_by.to_s
        end
        opts.on('-l', '--limit INTEGER', 'How many results to show at once. Default: 10') do |limit|
          options[:limit] = limit.to_i
        end
        opts.on('-I', '--IP IP_ADDRESS', 'IP address to use for geolocation lookup. Default: Your public IP') do |ip|
          options[:ip_address] = ip.to_s
        end
        opts.on('-v', '--version', 'Display the program version') do
          puts logo
          puts "     Version #{VERSION}"
          exit
        end
        opts.on('-h', '--help', 'Display a helpful usage guide') do
          puts opts
          exit
        end
      end.parse!
    end

    def logo
      "
         ( (
         ) )
       ........
       |      | ]
       \\      /
        `----'

     coffeefinder

    Results by Yelp
      "
    end

    def spaces(search_total)
      string = ' '
      Math.log10([1, search_total].max).to_i.times do
        string << ' '
      end
      string
    end

    def inverse_spaces(iteration_count, search_total)
      string = ''
      (Math.log10([1, search_total].max).to_i -
        Math.log10(iteration_count + 1).to_i
      ).times do
        string << ' '
      end
      string
    end

    def separator(string)
      separator = ''
      string.length.times do
        separator << '─'
      end
      separator
    end

    def meters_to_miles(distance)
      distance *= 0.000621371
      if distance >= 0.1
        "#{distance.truncate(2)} miles"
      else
        "#{(distance * 5280).to_i} feet"
      end
    end

    def main_menu
      yelp.clear_searches
      puts logo + "\n"
      choice = prompt.select('Choose an action:') do |menu|
        menu.default 1
        menu.choice 'Show nearby coffee shops', 1
        menu.choice 'Show any nearby business that has coffee', 2
        menu.choice 'Search for coffee near a certain adress', 3
        menu.choice 'Quit', 4
      end
      case choice
      when 1
        yelp.strict = true
        yelp.get_nearby_query_data
        display_search_results('nearby')
      when 2
        yelp.strict = false
        yelp.get_nearby_query_data
        display_search_results('nearby')
      when 3
        yelp.address = prompt.ask('Enter an address:', default: '11 Broadway, New York, NY')
        secondary_choice = prompt.select('Choose an action:') do |menu|
          menu.default 1
          menu.choice "Show coffee shops near #{yelp.address}", 1
          menu.choice "Show any business that has coffee near #{yelp.address}", 2
          menu.choice 'Quit', 3
        end
        case secondary_choice
        when 1
          yelp.strict = true
        when 2
          yelp.strict = false
        when 3
          exit(true)
        end
        yelp.get_address_query_data
        display_search_results('address')
      when 4
        exit(true)
      end
      nil
    end

    def display_search_results(query_type)
      puts "\n#{yelp.data.search.total} results found:\n\n" unless yelp.offset.positive?
      count = 0
      while count < yelp.data.search.total
        table = TTY::Table.new(
          header: %w[Number Name Distance]
        )
        yelp.data.search.business.each do |business_object|
          business = Business.find_or_create_by_id(business_object)
          table << ({ 'Number' => (count + 1), 'Name' => business.name, 'Distance' => meters_to_miles(business.distance) })
          # puts "#{spaces(yelp.data.search.total)}- - - - - - -"
          # puts "#{count + 1}#{inverse_spaces(count, yelp.data.search.total)}| #{business.name}"
          # puts "#{spaces(yelp.data.search.total)}| * About #{meters_to_miles(business.distance)} away"
          count += 1
        end
        puts table.render(
          :unicode,
          alignments: %i[center left center]
        )
        break unless count < yelp.data.search.total

        puts separator('Keep searching?')
        continue = prompt.yes?('Keep searching?')
        break unless continue

        yelp.offset = count
        if query_type == 'nearby'
          yelp.get_nearby_query_data
        elsif query_type == 'address'
          yelp.get_address_query_data
        else
          puts 'Error: invalid query type detected'
        end
      end
      puts separator('All results shown.')
      puts "All results shown.\n"
      puts separator('All results shown.')
      if yelp.data.search.total.positive?
        search_complete_menu
      else
        choice = prompt.select('Choose an action:') do |menu|
          menu.default 1
          menu.choice 'Return to the main menu', 1
          menu.choice 'Quit', 2
        end
        if choice == 1
          main_menu
        else
          exit(true)
        end
      end
      nil
    end

    def search_complete_menu
      yelp.offset = 0
      choice = prompt.select('Choose an action:') do |menu|
        menu.default 1
        menu.choice 'Display a business', 1
        menu.choice 'Return to the main menu to search again', 2
        menu.choice 'Quit', 3
      end
      case choice
      when 1
        business_menu
      when 2
        main_menu
      when 3
        exit(true)
      end
      nil
    end

    def longest_name
      yelp.businesses.max_by do |business|
        business.name.length
      end.name
    end

    def longest_distance
      yelp.businesses.max_by do |business|
        meters_to_miles(business.distance).length
      end.name
    end

    def space_evenly(longer_string, shorter_string)
      spaces = ''
      (longer_string.length - shorter_string.length).times do
        spaces << ' '
      end
      spaces
    end

    def business_menu
      yelp.searches_to_business_instances
      choices = yelp.businesses.collect do |business|
        { name: "#{business.name}#{space_evenly(longest_name, business.name)} - #{meters_to_miles(business.distance)} away#{space_evenly(longest_distance, meters_to_miles(business.distance))}",
          value: business.id }
      end
      choices.push([{ name: 'Return to the main menu to search again', value: 'Return' },
                    { name: 'Quit', value: 'Quit' }])
      choice = prompt.select('Choose an action or a business to display info for:', choices, per_page: 12)
      case choice
      when 'Return'
        main_menu
      when 'Quit'
        exit(true)
      else
        display_business(choice)
      end
      search_complete_menu
      nil
    end

    def display_business(id)
      business = yelp.businesses.find do |business_instance|
        business_instance.id == id
      end
      table = TTY::Table.new(
        header: %w[Attribute Value]
      )
      table << { 'Atribute' => 'Name', 'Value' => business.name }
      table << { 'Atribute' => 'Rating', 'Value' => business.rating }
      table << { 'Atribute' => 'Reviews', 'Value' => business.review_count }
      table << { 'Atribute' => 'Distance', 'Value' => meters_to_miles(business.distance) }
      table << { 'Atribute' => 'Price', 'Value' => business.price }
      table << { 'Atribute' => 'Address', 'Value' => business.address }
      table << { 'Atribute' => 'City', 'Value' => business.city }
      table << { 'Atribute' => 'Open now', 'Value' => business.open_now ? 'Yes' : 'No' }
      puts table.render(
        :unicode,
        alignments: %i[center left]
      )
      puts separator("Attribute | #{business.name} |")
      puts "Url: #{business.url}"
      puts separator("Attribute | #{business.name} |")
      # puts separator("Name: #{business.name}")
      # puts <<~STRING
      #   Name: #{business.name}
      #   Url: #{business.url}
      #   Rating: #{business.rating} stars
      #   Reviews: #{business.review_count}
      #   Distance: #{meters_to_miles(business.distance)}
      #   Price: #{business.price}
      #   Phone: #{business.phone}
      #   Address: #{business.address}
      #   City: #{business.city}
      #   Open now: #{business.open_now ? 'Yes' : 'No'}
      # STRING
      # puts separator("Name: #{business.name}")
      business
    end

    private

    attr_writer :options, :prompt, :limit, :radius, :ip_address, :sort_by, :strict
  end
end
