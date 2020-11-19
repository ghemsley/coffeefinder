require 'coffeefinder/secrets'
require 'coffeefinder/constants'
require 'coffeefinder/queries'
require 'coffefinder/geoip'
require 'graphlient'

module Coffeefinder
  class Yelp
    def initialize
      self.client = self.class.create_client
      self.variables = { cursor: cursor }
    end

    def self.create_client
      client = Graphlient::Client.new('https://api.yelp.com/v3/graphql',
                                      headers: {
                                        'Authorization' => "Bearer #{API_KEY}"
                                      },
                                      http_options: {
                                        read_timeout: 30
                                      })
      client
    end
  end
end
