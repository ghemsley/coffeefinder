module Coffeefinder
  class Prompt
    include Formatting
    attr_reader :prompt, :options, :favorites
    def initialize(options, favorites)
      self.prompt = TTY::Prompt.new
      self.options = options
      self.favorites = favorites
    end

    def main_menu_prompt
      prompt.select('Choose an action:') do |menu|
        menu.default 1
        menu.choice 'Show nearby coffee shops', 1
        menu.choice 'Show any nearby business that has coffee', 2
        menu.choice 'Search for coffee near a certain address', 3
        if favorites.empty?
          menu.choice 'Quit', 4
        else
          menu.choice 'View a favorited business', 4
          menu.choice 'Clear favorite businesses', 5
          menu.choice 'Quit', 6
        end
      end
    end

    def address_prompt
      prompt.ask('Enter an address:', default: DEFAULT_ADDRESS)
    end

    def main_menu_secondary_prompt(yelp)
      prompt.select('Choose an action:') do |menu|
        menu.default 1
        menu.choice "Show coffee shops near #{yelp.address}", 1
        menu.choice "Show any business that has coffee near #{yelp.address}", 2
        menu.choice 'Quit', 3
      end
    end

    def keep_searching_prompt
      prompt.yes?('Keep searching?')
    end

    def search_complete_prompt
      prompt.select('Choose an action:') do |menu|
        menu.default 1
        menu.choice 'Display a business', 1
        menu.choice 'Save a business to favorites', 2
        menu.choice 'Return to the main menu', 3
        menu.choice 'Quit', 4
      end
    end

    def search_results_empty_prompt
      prompt.select('Choose an action:') do |menu|
        menu.default 1
        menu.choice 'Return to the main menu', 1
        menu.choice 'Quit', 2
      end
    end

    def business_menu_prompt(yelp)
      businesses = fix_businesses_distance_sorting(yelp.businesses, options[:sort_by])
      choices = businesses.collect do |business|
        build_sorted_business_choice(options: options, yelp: yelp, business: business)
      end
      choices.push([{ name: 'Return to the main menu to search again', value: 'Return' },
                    { name: 'Quit', value: 'Quit' }])
      prompt.select('Choose an action or a business to display info for:', choices, per_page: options[:limit] + 2)
    end

    def save_business_menu_prompt(yelp)
      businesses = fix_businesses_distance_sorting(yelp.businesses, options[:sort_by])
      choices = businesses.collect do |business|
        build_sorted_business_choice(options: options, yelp: yelp, business: business)
      end
      choices.push([{ name: 'Return to the main menu to search again', value: 'Return' },
                    { name: 'Quit', value: 'Quit' }])
      prompt.select('Choose an action or a business to save to favorites:', choices, per_page: options[:limit] + 2)
    end

    def save_business_prompt
      prompt.yes?('Save business to favorites?')
    end

    def favorites_menu_prompt(yelp, favorites)
      sort_favorites(options, favorites)
      choices = favorites.collect.with_index(1) do |business, index|
        business.number = index
        build_sorted_business_choice(options: options, yelp: yelp, business: business)
      end
      choices.push([{ name: 'Return to the main menu', value: 'Return' },
                    { name: 'Quit', value: 'Quit' }])
      prompt.select('Choose an action or a business to display info for:', choices, per_page: options[:limit] + 2)
    end

    def clear_favorites_prompt
      prompt.yes?('Clear all favorites?')
    end

    private

    attr_writer :prompt, :options, :favorites
  end
end
