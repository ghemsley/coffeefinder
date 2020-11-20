require 'coffeefinder/secrets'
require 'coffeefinder/constants'
require 'coffeefinder/query'
require 'graphlient'

module Coffeefinder
  class Yelp
    attr_accessor :latitude, :longitude, :radius, :limit, :sort_by, :offset
    attr_reader :variables, :data, :client
    def initialize(args = { latitude: 42.0307,
                            longitude: -87.8107,
                            radius: 500.0,
                            limit: 10,
                            sort_by: 'best_match',
                            offset: 0 })
      self.client = self.class.create_client
      args.each do |key, value|
        send("#{key}=", value)
      end
      self.variables = { latitude: latitude, longitude: longitude, radius: radius, limit: limit, sort_by: sort_by }
    end

    def update_variables
      variables[:latitude] = latitude
      variables[:longitude] = longitude
      variables[:radius] = radius
      variables[:limit] = limit
      variables[:sort_by] = sort_by
      variables[:offset] = offset
    end

    def query(query_type)
      case query_type
      when 'nearby'
        update_variables
        self.data = client.query(Query.nearby, variables).data
      when 'nearby_strict'
        update_variables
        self.data = client.query(Query.nearby_strict, variables).data
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

    private

    attr_writer :variables, :data, :client

  end
end
