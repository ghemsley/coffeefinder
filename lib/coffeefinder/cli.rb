module Coffeefinder
  class CLI
    include Formatting
    attr_accessor :geoip, :yelp, :prompt, :parser
    attr_reader :options, :limit, :radius, :ip_address, :sort_by, :count, :table

    def initialize
      self.parser = Parser.new
      self.options = parser.options
      self.limit = options[:limit] || DEFAULT_LIMIT
      self.radius = options[:radius] || DEFAULT_RADIUS
      self.sort_by = options[:sort_by] || DEFAULT_SORT
      self.ip_address = options[:ip_address]
      self.prompt = Prompt.new(options)
      self.table = Table.new(options)
    end

    def main_menu
      yelp.clear_searches
      puts LOGO + "\n"
      choice = prompt.main_menu_prompt
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
        yelp.address = prompt.address_prompt
        secondary_choice = prompt.main_menu_secondary_prompt(yelp)
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

    def search_complete_menu
      yelp.offset = 0
      choice = prompt.search_complete_prompt
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

    def display_search_results(query_type)
      puts "\n#{yelp.data.search.total} results found\n\n" unless yelp.offset.positive?
      self.count = 0
      while count < yelp.data.search.total
        self.count = table.search_result_table(yelp, self.count)
        break unless count < yelp.data.search.total

        puts separator('Keep searching?')
        continue = prompt.keep_searching_prompt
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
      print_all_results_shown if count == yelp.data.search.total
      if yelp.data.search.total.positive?
        search_complete_menu
      else
        choice = prompt.search_results_empty_prompt
        if choice == 1
          main_menu
        else
          exit(true)
        end
      end
      nil
    end

    def display_business(id)
      business = yelp.find_business(id)
      table.business_table(business)
      display_business_url(business)
      business
    end

    def business_menu
      yelp.searches_to_business_instances
      choice = prompt.business_menu_prompt(yelp)
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

    private

    attr_writer :options, :limit, :radius, :ip_address, :sort_by, :strict, :count, :table
  end
end
