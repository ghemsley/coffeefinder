require 'coffeefinder/secrets'
require 'coffeefinder/constants'
require 'coffeefinder/query'
require 'coffeefinder/geoip'
require 'graphlient'

module Coffeefinder
  class Yelp
    def initialize
      self.client = self.class.create_client
      self.variables = { cursor: cursor }
    end

    def query(query_type)
      case query_type
      when 'nearby'
        variables[:latitude] = latitude
        variables[:longitude] = longitude
        self.data = client.query(nearby_query, variables)
      when 'nearby_with_cursor'
        variables[:latitude] = latitude
        variables[:longitude] = longitude
        variables[:cursor] = cursor
        self.data = client.query(nearby_query_with_cursor, variables)
      end
      data
    end

    def self.create_client
      client = Graphlient::Client.new(YELP_API,
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
