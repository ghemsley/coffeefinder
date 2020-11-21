require 'optparse'
require 'coffeefinder/constants'
require 'coffeefinder/business'
require 'tty-prompt'
require 'pry'
module Coffeefinder
  class CLI
    attr_accessor :geoip, :yelp
    attr_reader :options, :prompt, :limit, :radius, :ip_address, :sort_by, :strict, :data, :searches

    def initialize
      self.options = {}
      create_option_parser
      self.limit = options[:limit] || 10
      self.radius = options[:radius] || 0.25
      miles_to_meters
      self.ip_address = options[:ip_address] || ''
      self.sort_by = options[:sort_by] || 'best_match'
      self.strict = true
      self.prompt = TTY::Prompt.new
      self.searches = []
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
        opts.on('-r', '--radius MILES', 'How big of an area to search, in miles. Default: 0.25') do |radius|
          options[:radius] = radius.to_f
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
          puts VERSION
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
      separator = '-'
      (string.length / 2).times do
        separator << ' -'
      end
      separator
    end

    def miles_to_meters
      options[:radius] = options[:radius] * 1609.34
    end

    def meters_to_km(distance)
      if distance >= 1000
        "#{(distance / 1000).truncate(2)} km"
      else
        "#{distance.to_i} meters"
      end
    end

    def get_nearby_query_data
      strict ? yelp.query('nearby_strict') : yelp.query('nearby')
      self.data = yelp.data
      save_search(data.search)
      data
    end

    def save_search(search)
      searches.push(search)
      searches
    end

    def clear_searches
      searches.clear
      searches
    end

    def searches_to_business_instances
      businesses = []
      searches.each do |search|
        search.business.each do |business|
          businesses.push(business)
        end
      end
      businesses.collect do |business|
        Business.find_or_create_by_id(business)
      end
    end

    def main_menu
      system 'clear' unless Business.all.empty?
      clear_searches
      puts logo + "\n"
      choice = prompt.select('Choose an action:') do |menu|
        menu.default 1
        menu.choice 'Show nearby coffee shops', 1
        menu.choice 'Show any nearby business that has coffee', 2
        menu.choice 'Quit', 3
      end
      case choice
      when 1
        self.strict = true
      when 2
        self.strict = false
      when 3
        exit(true)
      end
      get_nearby_query_data
      display_search_results
      nil
    end

    def display_search_results
      yelp.update_variables
      puts "\n#{data.search.total} results found:\n\n" unless yelp.offset.positive?
      count = 0
      while count <= data.search.total
        data.search.business.each do |business_object|
          business = Business.find_or_create_by_id(business_object)
          puts "#{spaces(data.search.total)}- - - - - - -"
          puts "#{count + 1}#{inverse_spaces(count, data.search.total)}| #{business.name}"
          puts "#{spaces(data.search.total)}| * About #{distance_to_km(business.distance)} away"
          count += 1
        end
        break unless count < data.search.total

        puts "#{spaces(data.search.total)}- - - - - - -"
        continue = prompt.yes?('Keep searching?')
        break unless continue

        yelp.offset = count
        get_nearby_query_data
      end
      puts "All results shown.\n"
      search_complete_menu
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

    def business_menu
      system 'clear'
      choices = searches_to_business_instances.collect do |business|
        { name: "View #{business.name} - #{distance_to_km(business.distance)} away", value: business.id }
      end
      choices.push([{ name: 'Return to the main menu to search again', value: 'Return' },
                    { name: 'Quit', value: 'Quit' }])
      choice = prompt.select('Choose an action or a business to display info for:', choices, per_page: 10)
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
      system 'clear'
      business = searches_to_business_instances.find do |business_instance|
        business_instance.id == id
      end
      puts separator("Name: #{business.name}")
      puts <<~STRING
        Name: #{business.name}
        Url: #{business.url}
        Rating: #{business.rating} stars
        Reviews: #{business.review_count}
        Distance: #{distance_to_km(business.distance)}
        Price: #{business.price}
        Phone: #{business.phone}
        Address: #{business.address}
        City: #{business.city}
        Open now: #{business.open_now ? 'Yes' : 'No'}
      STRING
      puts separator("Name: #{business.name}")
      business
    end

    private

    attr_writer :options, :prompt, :limit, :radius, :ip_address, :sort_by, :strict, :data, :searches
  end
end
