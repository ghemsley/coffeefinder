require 'optparse'
require 'coffeefinder/constants'
require 'coffeefinder/business'
module Coffeefinder
  class CLI
    attr_reader :yelp, :geoip, :options, :limit, :radius, :ip_address, :sort_by, :strict

    def initialize
      self.options = {}
      create_option_parser
      self.limit = options[:limit] || 10
      self.radius = options[:radius] || 500.0
      self.ip_address = options[:ip_address] || ''
      self.sort_by = options[:sort_by] || 'best_match'
      self.strict = options[:strict] || false
    end

    def geoip=(geoip)
      puts "Obtaining geolocation data for IP address#{ip_address != '' ? " #{ip_address}" : ''}..."
      @geoip = geoip
    end

    def yelp=(yelp)
      puts 'Authenticating with Yelp...'
      @yelp = yelp
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
        opts.on('-I', '--IP IP_ADDRESS', 'IP address to use for geolocation lookup') do |ip|
          options[:ip_address] = ip.to_s
        end
        opts.on('-r', '--radius FLOAT', 'How big of an area to search, in meters') do |radius|
          options[:radius] = radius.to_f
        end
        opts.on('-l', '--limit INTEGER', 'How many results to show at once') do |limit|
          options[:limit] = limit.to_i
        end
        opts.on('-s', '--sort_by STRING', "How to sort results. Acceptable values: 'distance', 'rating', 'review_count', 'best_match'") do |sort_by|
          options[:sort_by] = sort_by.to_s
        end
        opts.on('-S', '--STRICT', 'Use a stricter search method. Less results but also less false positives.') do
          options[:strict] = true
        end
        opts.on('-v', '--version', 'Display the program version. Overrides all other option behaviors') do
          puts VERSION
          exit
        end
        opts.on('-h', '--help', 'Displays a helpful usage guide. Overrides all other option behaviors') do
          puts opts
          exit
        end
      end.parse!
    end

    def spaces(iteration_count)
      string = ''
      (3 - (Math.log10(iteration_count).to_i + 1)).times do
        string << ' '
      end
      string
    end

    def get_nearby_query_data
      strict ? yelp.query('nearby_strict') : yelp.query('nearby')
      yelp.data
    end

    def search_nearby
      puts "Press enter to list nearby coffee shops, or type q to quit:\n"
      input = gets.chomp.strip.downcase
      count = 1
      puts "Looking for nearby coffee shops...\n\n"
      data = get_nearby_query_data
      puts "Total nearby coffee shops: #{data.search.total}\n\n"
      while input != 'q' && count <= data.search.total && (data.search.total > yelp.limit || count < data.search.total)
        data.search.business.each do |business_object|
          business = Business.new(business_object, count)
          puts "#{count}#{spaces(count)}| #{business.name}"
          count += 1
        end
        next unless count < data.search.total && data.search.total > yelp.limit

        until (input == instance_of?(Integer) && number <= count && number.positive?) || input == "\n"
          puts "\nPress enter to list more nearby coffee shops, type a number to view a certain business, or type q to quit:\n"
          input = gets.chomp.strip.downcase
          if input.instance_of?(Integer)
            display_business(input)
          elsif input == "\n"
            yelp.offset = count
            yelp.update_variables
            data = get_nearby_query_data
          else
            puts 'Your input seems to be invalid, please try again.'
          end
        end
        puts 'Enter a number to view the corresponding business, or type q to quit: '
      end

      # rescue NoMethodError || NameError
    end

    def display_business(number)
      business = Business.all.find do |business_object|
        business_object.number == number
      end
      puts <<~STRING
        #{business.number}#{spaces(number)}| Name: #{business.name}
        #{spaces(number)}  Url: #{business.url}
        #{spaces(number)}  Rating: #{business.rating}
        #{spaces(number)}  Reviews: #{business.review_count}
        #{spaces(number)}  Distance: #{business.distance}
        #{spaces(number)}  Price range: #{business.price}
        #{spaces(number)}  Phone: #{business.phone}
        #{spaces(number)}  Address: #{business.address}
        #{spaces(number)}  City: #{business.city}
        #{spaces(number)}  Open now: #{business.open_now ? 'Yes' : 'No'}
      STRING
    end

    private

    attr_writer :options, :limit, :radius, :ip_address, :sort_by, :strict
  end
end
