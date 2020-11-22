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
        opts.on('-r', '--radius MILES', 'How big of an area to search, in miles. Default: 0.5, max 10') do |radius|
          raise ParserError unless (0..10).include?(radius.to_f)

          options[:radius] = [radius.to_f * 1609.34, 16_093.4].min || DEFAULT_RADIUS
        end
        opts.on('-s', '--sort_by STRING', "How to sort results. Acceptable values: 'distance', 'rating', 'review_count', 'best_match'. Default: 'best_match'") do |sort_by|
          raise ParserError unless %w[distance rating review_count best_match].include?(sort_by)

          options[:sort_by] = sort_by.to_s || DEFAULT_SORT
        end
        opts.on('-l', '--limit INTEGER', 'How many results to show at once. Default: 10, max: 50') do |limit|
          raise ParserError unless (1..50).include?(limit.to_i)

          options[:limit] = limit.to_i || DEFAULT_LIMIT
        end
        opts.on('-i', '--ip IP_ADDRESS', 'IP address to use for geolocation lookup. Default: Your public IP') do |ip|
          raise ParserError unless IP_ADDRESS_REGEX.match?(ip)

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
    rescue OptionParser::MissingArgument
      puts ParserError.message
      exit(false)
    rescue ParserError
      puts ParserError.message
      exit(false)
    end

    class ParserError < StandardError
      extend Formatting
      def self.message
        puts separator('Please check the provided options for validity and try again.')
        puts 'One or more of the arguments provided seem to be invalid.'
        puts 'Please check the provided options for validity and try again.'
        puts separator('Please check the provided options for validity and try again.')
      end
    end

    private

    attr_writer :options
  end
end
