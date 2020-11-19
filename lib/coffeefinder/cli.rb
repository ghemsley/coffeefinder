require 'optparse'
require 'coffeefinder/constants'
module Coffeefinder
  class CLI
    attr_accessor :yelp, :geoip
    attr_reader :options, :limit, :radius, :ip_address

    def initialize
      self.options = {}
      create_option_parser
      self.limit = options[:limit] || 10
      self.radius = options[:radius] || 500.0
      self.ip_address = options[:ip_address] || ''
      puts "Performing geolocation lookup for IP #{ip_address}..." if options[:ip]
    end

    def create_option_parser
      OptionParser.new do |opts|
        opts.banner = 'Usage: coffeefinder [options]'
        opts.on('-I', '--IP IP_ADDRESS', 'IP address to use for geolocation lookup') do |ip|
          options[:ip_address] = ip.to_s
        end
        opts.on('-r', '--radius FLOAT', 'How big of an area to search, in meters') do |radius|
          options[:radius] = radius.to_f
        end
        opts.on('-l', '--limit INTEGER', 'How many results to show at once') do |limit|
          options[:limit] = limit.to_i
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

    def search_nearby
      yelp.query('nearby')
      data = yelp.data
      print "Press enter to list nearby coffee shops, or press q at any time to quit:\n"
      input = gets.chomp.strip.downcase
      count = 0
      while input != 'q' && count < data.search.total
        data.search.business.each do |business|
          puts "#{count + 1}#{case count
                              when count < 10
                                print ''
                              when count > 9
                                print ' '
                              when count > 99
                                print '  '
                              end
                            }| #{business.name}"
          count += 1
        end
      end
      # rescue NoMethodError || NameError
    end

    private

    attr_writer :options, :results, :radius, :ip_address
  end
end
