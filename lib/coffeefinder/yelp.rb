require 'coffeefinder/secrets'
require 'coffeefinder/constants'
require 'coffeefinder/query'
require 'coffeefinder/geoip'
require 'graphlient'

module Coffeefinder
  class Yelp
    attr_accessor :latitude, :longitude, :radius, :results
    attr_reader :variables, :data
    def initialize(latitude = 42.0307, longitude = -87.8107, radius = 500.0, limit = 10)
      puts 'Authenticating with Yelp...'
      self.client = self.class.create_client
      self.latitude = latitude
      self.longitude = longitude
      self.radius = radius
      self.limit = limit
      self.variables = { latitude: latitude, longitude: longitude, radius: radius, limit: limit }
    end

    def query(query_type)
      case query_type
      when 'nearby'
        puts 'Looking for nearby coffee shops...'
        variables[:latitude] = latitude
        variables[:longitude] = longitude
        variables[:radius] = radius
        variables[:results] = results
        self.data = client.query(Query.nearby, variables).data
      end
      data
    end

    def self.create_client
      puts 'Authenticating with Yelp...'
      client = Graphlient::Client.new(YELP_API,
                                      headers: {
                                        'Authorization' => "Bearer #{API_KEY}"
                                      },
                                      http_options: {
                                        read_timeout: 30
                                      })
      client
    end

    private

    attr_writer :variables, :data
  end
end
