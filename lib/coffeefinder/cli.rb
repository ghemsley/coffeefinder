require 'optparse'
require 'coffeefinder/constants'
module Coffeefinder
  class CLI
    attr_reader :options

    def initialize
      self.options = {}
    end

    def create_option_parser
      OptionParser.new do |opts|
        opts.banner = 'Usage: coffeefinder [options]'
        opts.on('-P', '--PAGINATION INTEGER', 'How many results to show at once for paginated displays of data') do |pagination|
          options[:pagination] = pagination
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

    private

    attr_writer :options
  end
end
