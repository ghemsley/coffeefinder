require 'optparse'
require 'coffeefinder/constants'
module Coffeefinder
  class CLI
    attr_reader :options

    def initialize
      self.options = {}
      create_option_parser
      self.results = options[:results] || 20
      puts "Performing geolocation lookup for IP #{ip}..." if options[:ip]
    end

    def create_option_parser
      OptionParser.new do |opts|
        opts.banner = 'Usage: coffeefinder [options]'
        opts.on('-I', '--IP STRING', 'IP address to use for geolocation lookup') do |ip|
          options[:ip] = ip.to_s
        end
        opts.on('-R', '--RESULTS INTEGER', 'How many results to show at once') do |results|
          options[:results] = results.to_i if results
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

    def search_nearby(yelp)
      yelp.query('nearby')
      data = yelp.data
      print "Press enter to list nearby coffee shops, or press q at any time to quit:\n"
      input = gets.chomp.strip.downcase
      count = 0
      begin
        while input != 'q' && count < data
          data.each do |node|
            puts "#{count + 1}#{case count
                                when count < 10
                                  print ''
                                when count > 9
                                  print ' '
                                when count > 99
                                  print '  '
                                end
                              }| #{node.name}"
            count += 1
          end
          puts "\nPress enter to continue or q to quit:\n" if count < data
          input = gets.chomp.strip.downcase
          yelp.query('nearby')
          data = yelp.data
        end
      # rescue NoMethodError || NameError

      end
    end

    private

    attr_writer :options
  end
end
