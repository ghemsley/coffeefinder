module Coffeefinder
  module Formatting
    def spaces(search_total)
      string = ' '
      Math.log10([1, search_total].max).to_i.times do
        string << ' '
      end
      string
    end

    def inverse_spaces(number, search_total)
      string = ''
      (Math.log10([1, search_total].max).to_i -
        Math.log10([1, number].max).to_i
      ).times do
        string << ' '
      end
      string
    end

    def separator(string)
      separator = ''
      [string.length, `tput cols`.to_i].min.times do
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

    def space_evenly(longer_string, shorter_string)
      spaces = ''
      (longer_string.length - shorter_string.length).times do
        spaces << ' '
      end
      spaces
    end

    def longest_name(yelp)
      yelp.businesses.max_by do |business|
        business.name.length
      end.name
    end

    def longest_distance(yelp)
      yelp.businesses.max_by do |business|
        meters_to_miles(business.distance).length
      end.name
    end

    def print_all_results_shown
      puts separator('All results shown.')
      puts "All results shown.\n"
      puts separator('All results shown.')
    end

    def sort_by_string(sort_by)
      case sort_by
      when 'rating'
        'Rating'
      when 'distance'
        'Distance'
      when 'best_match'
        'Rating'
      when 'review_count'
        'Reviews'
      else
        'Rating'
      end
    end

    def display_business_url(business)
      puts separator("Url: #{business.url}")
      puts "Url: #{business.url}"
      puts separator("Url: #{business.url}")
      nil
    end

    def fix_businesses_distance_sorting(businesses, sort_by)
      if sort_by == 'distance'
        businesses.sort_by!(&:distance)
        businesses.each.with_index(1) do |business, index|
          business.number = index
        end
      end
      businesses
    end
  end
end
