module Coffeefinder
  class Prompt
    include Formatting
    attr_reader :prompt, :options
    def initialize(options)
      self.prompt = TTY::Prompt.new
      self.options = options
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

    def address_prompt
      prompt.ask('Enter an address:', default: '11 Broadway, New York, NY')
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
        menu.choice 'Return to the main menu to search again', 2
        menu.choice 'Quit', 3
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

    private

    attr_writer :prompt, :options
  end
end
