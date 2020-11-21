require 'coffeefinder/cli'
require 'coffeefinder/geoip'
require 'coffeefinder/yelp'
module Coffeefinder
  class Error < StandardError; end
  cli = CLI.new
  print "Obtaining geolocation data for IP address#{cli.ip_address != '' ? " #{cli.ip_address}" : ''}... "
  cli.geoip = GeoIP.new(cli.ip_address)
  print "Obtained!\n"
  print 'Authenticating with Yelp... '
  cli.yelp = Yelp.new({
                        latitude: cli.geoip.latitude,
                        longitude: cli.geoip.longitude,
                        radius: cli.radius,
                        limit: cli.limit,
                        sort_by: cli.sort_by,
                        offset: 0
                      })
  print "Authenticated!\n"

  cli.main_menu
end
