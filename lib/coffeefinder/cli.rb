require 'tty-prompt'
require 'tty-table'
module Coffeefinder
  class CLI
    include Formatting
    attr_accessor :geoip, :yelp, :prompt, :parser
    attr_reader :options, :limit, :radius, :ip_address, :sort_by, :count

    def initialize
      self.parser = Parser.new
      self.options = parser.options
      self.limit = options[:limit] || DEFAULT_LIMIT
      self.radius = options[:radius] || DEFAULT_RADIUS
      self.sort_by = options[:sort_by] || DEFAULT_SORT
      self.ip_address = options[:ip_address]
      self.prompt = TTY::Prompt.new
    end

    def main_menu_prompt
      prompt.select('Choose an action:') do |menu|
        menu.default 1
        menu.choice 'Show nearby coffee shops', 1
        menu.choice 'Show any nearby business that has coffee', 2
        menu.choice 'Search for coffee near a certain address', 3
        menu.choice 'Quit', 4
      end
    end

    def main_menu_secondary_prompt
      prompt.select('Choose an action:') do |menu|
        menu.default 1
        menu.choice "Show coffee shops near #{yelp.address}", 1
        menu.choice "Show any business that has coffee near #{yelp.address}", 2
        menu.choice 'Quit', 3
      end
    end

    def main_menu
      yelp.clear_searches
      puts LOGO + "\n"
      choice = main_menu_prompt
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
        secondary_choice = main_menu_secondary_prompt
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

    def display_table
      table = TTY::Table.new(
        header: ['Number', 'Name', sort_by_string(options[:sort_by])]
      )
      yelp.data.search.business.each do |business_object|
        business = Business.find_or_create_by_id(business_object)
        business.number = count + 1
        table << case options[:sort_by]
                 when 'best_match'
                   { 'Number' => (count + 1),
                     'Name' => business.name,
                     'Rating' => "#{business.rating} stars" }
                 when 'distance'
                   { 'Number' => (count + 1),
                     'Name' => business.name,
                     'Distance' => meters_to_miles(business.distance) }
                 when 'rating'
                   { 'Number' => (count + 1),
                     'Name' => business.name,
                     'Rating' => "#{business.rating} stars" }
                 when 'review_count'
                   { 'Number' => (count + 1),
                     'Name' => business.name,
                     'Reviews' => "#{business.review_count} reviews" }
                 else
                   { 'Number' => (count + 1),
                     'Name' => business.name,
                     'Rating' => "#{business.rating} stars" }
                 end
        self.count += 1
      end
      puts table.render(
        :unicode,
        alignments: %i[center left left]
      )
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

    def search_results_empty_prompt
      prompt.select('Choose an action:') do |menu|
        menu.default 1
        menu.choice 'Return to the main menu', 1
        menu.choice 'Quit', 2
      end
    end

    def display_search_results(query_type)
      puts "\n#{yelp.data.search.total} results found\n\n" unless yelp.offset.positive?
      self.count = 0
      while count < yelp.data.search.total
        display_table
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
      print_all_results_shown
      if yelp.data.search.total.positive?
        search_complete_menu
      else
        choice = search_results_empty_prompt
        if choice == 1
          main_menu
        else
          exit(true)
        end
      end
      nil
    end

    def build_business_menu_choices
      choices = yelp.businesses.collect do |business|
        case options[:sort_by]
        when 'best_match'
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.data.search.total)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.rating} star#{business.rating != 1 ? 's' : ''}",
            value: business.id }
        when 'distance'
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.data.search.total)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{meters_to_miles(business.distance)} away",
            value: business.id }
        when 'rating'
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.data.search.total)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.rating} star#{business.rating != 1 ? 's' : ''}",
            value: business.id }
        when 'review_count'
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.data.search.total)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.review_count} review#{business.review_count < 2 ? '' : 's'}",
            value: business.id }
        else
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.data.search.total)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.rating} star#{business.rating != 1 ? 's' : ''}",
            value: business.id }
        end
      end
      choices.push([{ name: 'Return to the main menu to search again', value: 'Return' },
                    { name: 'Quit', value: 'Quit' }])
      prompt.select('Choose an action or a business to display info for:', choices, per_page: 12)
    end

    def business_menu
      yelp.searches_to_business_instances
      choice = build_business_menu_choices
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

    def business_table(business)
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
      table.render(
        :unicode,
        alignments: %i[left left]
      )
    end

    def display_business_url(business)
      puts separator("Url: #{business.url}")
      puts "Url: #{business.url}"
      puts separator("Url: #{business.url}")
      nil
    end

    def display_business(id)
      business = yelp.find_business(id)
      puts business_table(business)
      display_business_url(business)
      business
    end

    private

    attr_writer :options, :limit, :radius, :ip_address, :sort_by, :strict, :count
  end
end
