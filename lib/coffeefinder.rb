require 'coffeefinder/cli'
require 'coffeefinder/constants'

module Coffeefinder
  class Error < StandardError; end
  cli = CLI.new
  yelp = Yelp.new

end
