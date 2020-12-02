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

    def build_sorted_business_choice(options:, yelp:, business:)
      case options[:sort_by]
      when 'best_match'
        begin
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.data.search.total)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.rating} star#{business.rating != 1 ? 's' : ''}",
            value: business.id }
        rescue GraphQL::Client::UnfetchedFieldError
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.businesses.length)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.rating} star#{business.rating != 1 ? 's' : ''}",
            value: business.id }
        end
      when 'distance'
        begin
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.data.search.total)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{meters_to_miles(business.distance)} away",
            value: business.id }
        rescue GraphQL::Client::UnfetchedFieldError
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.businesses.length)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{meters_to_miles(business.distance)} away",
            value: business.id }
        end
      when 'rating'
        begin
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.data.search.total)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.rating} star#{business.rating != 1 ? 's' : ''}",
            value: business.id }
        rescue GraphQL::Client::UnfetchedFieldError
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.businesses.length)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.rating} star#{business.rating != 1 ? 's' : ''}",
            value: business.id }
        end
      when 'review_count'
        begin
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.data.search.total)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.review_count} review#{business.review_count < 2 ? '' : 's'}",
            value: business.id }
        rescue GraphQL::Client::UnfetchedFieldError
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.businesses.lengthj)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.review_count} review#{business.review_count < 2 ? '' : 's'}",
            value: business.id }
        end
      else
        begin
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.data.search.total)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.rating} star#{business.rating != 1 ? 's' : ''}",
            value: business.id }
        rescue GraphQL::Client::UnfetchedFieldError
          { name: "#{business.number}#{inverse_spaces(business.number, yelp.businesses.length)}| #{business.name}#{space_evenly(longest_name(yelp), business.name)} - #{business.rating} star#{business.rating != 1 ? 's' : ''}",
            value: business.id }
        end
      end
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

    def sort_favorites(options, favorites)
      case options[:sort_by]
      when 'best_match'
        favorites.sort_by!(&:rating)
      when 'distance'
        favorites.sort_by!(&:distance)
      when 'rating'
        favorites.sort_by!(&:rating)
      when 'review_count'
        favorites.sort_by!(&:review_count)
      else
        favorites.sort_by!(&:rating)
      end
      favorites
    end
  end
end
