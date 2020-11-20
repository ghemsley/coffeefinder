require 'coffeefinder/cli'
require 'coffeefinder/geoip'
require 'coffeefinder/yelp'
module Coffeefinder
  class Error < StandardError; end
  cli = CLI.new
  cli.geoip = GeoIP.new(cli.ip_address)
  cli.yelp = Yelp.new({
                        latitude: cli.geoip.latitude,
                        longitude: cli.geoip.longitude,
                        radius: cli.radius,
                        limit: cli.limit,
                        sort_by: cli.sort_by
                      })
  cli.search_nearby(cli.options[:strict])
end
