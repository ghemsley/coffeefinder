require 'coffeefinder/secrets'
require 'coffeefinder/constants'
require 'coffeefinder/query'
require 'coffeefinder/geoip'
require 'graphlient'

module Coffeefinder
  class Yelp
    attr_accessor :latitude, :longitude, :radius, :limit, :sort_by
    attr_reader :variables, :data, :client
    def initialize(latitude = 42.0307, longitude = -87.8107, radius = 500.0, limit = 10, sort_by = 'best_match')
      self.client = self.class.create_client
      self.latitude = latitude
      self.longitude = longitude
      self.radius = radius
      self.limit = limit
      self.sort_by = sort_by
      self.variables = {
        latitude: self.latitude,
        longitude: self.longitude,
        radius: self.radius,
        limit: self.limit,
        sort_by: self.sort_by
      }
    end

    def update_variables
      variables[:latitude] = latitude
      variables[:longitude] = longitude
      variables[:radius] = radius
      variables[:limit] = limit
      variables[:sort_by] = sort_by
    end

    def query(query_type)
      case query_type
      when 'nearby'
        puts 'Looking for nearby coffee shops...'
        update_variables
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

    attr_writer :variables, :data, :client
  end
end
