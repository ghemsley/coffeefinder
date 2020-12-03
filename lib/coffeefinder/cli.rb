module Coffeefinder
  class CLI
    include Formatting
    attr_accessor :geoip, :yelp, :prompt, :parser
    attr_reader :options, :limit, :radius, :ip_address, :sort_by, :count, :table, :favorites

    def initialize
      self.parser = Parser.new
      self.options = parser.options
      self.limit = options[:limit] || DEFAULT_LIMIT
      self.radius = options[:radius] || DEFAULT_RADIUS
      self.sort_by = options[:sort_by] || DEFAULT_SORT
      self.ip_address = options[:ip_address]
      self.favorites = Favorites.new(FILE_PATH)
      self.prompt = Prompt.new(options, favorites.list)
      self.table = Table.new(options)
    end

    def main_menu
      yelp.clear_searches
      yelp.clear_businesses
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
        if favorites.list.empty?
          exit(true)
        else
          favorites_menu
        end
      when 5
        if favorites.list.empty?
          exit(true)
        else
          clear_favorites
        end
      when 6
        exit(true)
      else
        puts 'Error: something went wrong displaying the main menu'
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
        save_business_menu
      when 3
        main_menu
      when 4
        exit(true)
      end
      nil
    end

    def display_search_results(query_type)
      puts "\n#{yelp.data.search.total} results found\n\n" unless yelp.offset.positive?
      self.count = 0
      while count < yelp.data.search.total
        self.count = table.search_result_table(yelp, count)
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
      business_result = yelp.find_business(id)
      business = Business.find_or_create_by_id(business_result)
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

    def save_business(id)
      business = yelp.find_business(id)
      favorites.save_to_list(business)
      favorites.list
    end

    def save_business_menu
      yelp.searches_to_business_instances
      choice = prompt.save_business_menu_prompt(yelp)
      case choice
      when 'Return'
        main_menu
      when 'Quit'
        exit(true)
      else
        display_business(choice)
      end
      save_business(choice) if prompt.save_business_prompt
      search_complete_menu
      nil
    end

    def build_favorites_businesses
      favorites.list.collect do |favorite|
        yelp.id = favorite
        yelp.update_variables
        yelp.get_business_query_data
      end
      businesses = yelp.businesses.collect do |business_result|
        Business.find_or_create_by_id(business_result)
      end
      businesses
    end

    def favorites_menu(businesses = nil)
      choice = nil
      businesses ||= build_favorites_businesses
      while choice != 'Return' && choice != 'Quit'
        choice = prompt.favorites_menu_prompt(yelp, businesses)
        case choice
        when 'Remove'
          remove_favorite_menu(businesses)
        when 'Return'
          main_menu
        when 'Quit'
          exit(true)
        else
          display_business(choice)
        end
      end
      nil
    end

    def clear_favorites
      favorites.clear if prompt.clear_favorites_prompt
      main_menu
    end

    def remove_favorite(id, businesses)
      favorites.delete_from_list(id)
      businesses.delete_if do |business|
        business.id == id
      end
      main_menu if businesses.empty?
    end

    def remove_favorite_menu(businesses = nil)
      businesses ||= build_favorites_businesses
      choice = prompt.remove_favorite_prompt(yelp, businesses)
      case choice
      when 'Return'
        favorites_menu(businesses)
      when 'Quit'
        exit(true)
      else
        remove_favorite(choice, businesses) if prompt.confirm_remove_favorite_prompt
      end
      nil
    end

    private

    attr_writer :options, :limit, :radius, :ip_address, :sort_by, :strict, :count, :table, :favorites
  end
end
