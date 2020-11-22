module Coffeefinder
  VERSION = '0.1.0'.freeze
  BANNER = <<~BANNER.freeze

                ( (
                ) )
              ........
              |      | ]
              \\      /
               `----'

    Usage: coffeefinder [options]

  BANNER
  LOGO = "
         ( (
         ) )
       ........
       |      | ]
       \\      /
        `----'

     coffeefinder

    Results by Yelp
      ".freeze
  API_KEY = ENV["YELP_API_KEY"]
  YELP_API = 'https://api.yelp.com/v3/graphql'.freeze
  GEOIP_API = 'http://ip-api.com/json/'.freeze
  DEFAULT_LIMIT = 10
  DEFAULT_RADIUS = 805.0
  DEFAULT_SORT = 'best_match'.freeze
  DEFAULT_ADDRESS = '11 Broadway 2nd floor, New York, NY'.freeze
  IP_ADDRESS_REGEX = /(^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$)|(^([\d\w]{4}):([\d\w]{4}):([\d\w]{4}):([\d\w]{4}):([\d\w]{4}):([\d\w]{4}):([\d\w]{4}):([\d\w]{4})$)/i.freeze
end
