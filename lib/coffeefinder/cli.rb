require 'optparse'
require 'coffeefinder/constants'
require 'coffeefinder/business'
require 'tty-prompt'
module Coffeefinder
  class CLI
    attr_reader :yelp, :geoip, :options, :prompt, :limit, :radius, :ip_address, :sort_by, :strict, :data

    def initialize
      self.options = {}
      create_option_parser
      self.limit = options[:limit] || 10
      self.radius = options[:radius] || 500.0
      self.ip_address = options[:ip_address] || ''
      self.sort_by = options[:sort_by] || 'best_match'
      self.strict = true
      self.prompt = TTY::Prompt.new
    end

    def geoip=(geoip)
      print "Obtaining geolocation data for IP address#{ip_address != '' ? " #{ip_address}" : ''}... "
      @geoip = geoip
      print "Obtained!\n"
      self.geoip
    end

    def yelp=(yelp)
      print 'Authenticating with Yelp... '
      @yelp = yelp
      print "Authenticated!\n\n"
      self.yelp
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

    def get_nearby_query_data
      strict ? yelp.query('nearby_strict') : yelp.query('nearby')
      self.data = yelp.data
      data
    end

    def main_menu
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
          business = Business.new(business_object)
          puts "#{count + 1}#{inverse_spaces(count + 1, data.search.total)}| #{business.name}"
          puts "#{spaces(data.search.total)}| - About #{business.distance >= 1000 ? "#{business.distance / 1000} km away" : "#{business.distance.to_i} meters away"}"
          count += 1
        end
        break unless count < data.search.total
        continue = prompt.yes?('Show more results?')
        break unless continue
        yelp.offset = count
        get_nearby_query_data
      end
      nil
    end

    def display_business(number)
      business = Business.all.find do |business_object|
        business_object.number == number
      end
      puts <<~STRING

        Name: #{business.name}
        Url: #{business.url}
        Rating: #{business.rating} stars
        Reviews: #{business.review_count}
        Distance: #{business.distance} meters
        Price: #{business.price}
        Phone: #{business.phone}
        Address: #{business.address}
        City: #{business.city}
        Open now: #{business.open_now ? 'Yes' : 'No'}
      STRING
      business
    end

    private

    attr_writer :options, :prompt, :limit, :radius, :ip_address, :sort_by, :strict, :data
  end
end
