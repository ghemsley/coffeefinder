require 'coffeefinder/secrets'
require 'coffeefinder/constants'
require 'coffeefinder/query'
require 'coffeefinder/geoip'
require 'graphlient'

module Coffeefinder
  class Yelp
    attr_accessor :results
    def initialize
      self.client = self.class.create_client
      self.variables = { results: results }
    end

    def query(query_type)
      case query_type
      when 'nearby'
        puts 'Looking for nearby coffee shops...'
        variables[:results] = results
        variables[:latitude] = latitude
        variables[:longitude] = longitude
        self.data = client.query(Query.nearby, variables)
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
  end
end
