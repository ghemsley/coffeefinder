require 'coffeefinder/cli'
require 'coffeefinder/geoip'
require 'coffeefinder/yelp'
module Coffeefinder
  class Error < StandardError; end
  cli = CLI.new
  cli.geoip = GeoIP.new(cli.ip_address)
  cli.yelp = Yelp.new(cli.geoip.latitude, cli.geoip.longitude, cli.radius, cli.limit, cli.sort_by)
  cli.search_nearby
end
