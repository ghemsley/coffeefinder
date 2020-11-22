require_relative './concerns/constants'
require 'optparse'

module Coffeefinder
  class Parser
    attr_reader :options
    def initialize
      self.options = { radius: DEFAULT_RADIUS, sort_by: DEFAULT_SORT, limit: DEFAULT_LIMIT, ip_address: nil }
      create_option_parser
    end

    def create_option_parser
      OptionParser.new do |opts|
        opts.banner = BANNER
        opts.on('-r', '--radius MILES', 'How big of an area to search, in miles. Default: 0.5 miles, max 10 miles') do |radius|
          options[:radius] = [radius.to_f * 1609.34, 16_093.4].min || DEFAULT_RADIUS
        end
        opts.on('-s', '--sort_by STRING', "How to sort results. Acceptable values: 'distance', 'rating', 'review_count', 'best_match'. Default: 'best_match'") do |sort_by|
          options[:sort_by] = sort_by.to_s || DEFAULT_SORT
        end
        opts.on('-l', '--limit INTEGER', 'How many results to show at once. Default: 10') do |limit|
          options[:limit] = limit.to_i || DEFAULT_LIMIT
        end
        opts.on('-I', '--IP IP_ADDRESS', 'IP address to use for geolocation lookup. Default: Your public IP') do |ip|
          options[:ip_address] = ip.to_s
        end
        opts.on('-v', '--version', 'Display the program version') do
          puts LOGO
          puts "     Version #{VERSION}"
          exit
        end
        opts.on('-h', '--help', 'Display a helpful usage guide') do
          puts opts
          exit
        end
      end.parse!
    end

    private

    attr_writer :options
  end
end
