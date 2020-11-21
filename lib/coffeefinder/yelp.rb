require 'coffeefinder/secrets'
require 'coffeefinder/constants'
require 'coffeefinder/query'
require 'graphlient'

module Coffeefinder
  class Yelp
    attr_accessor :latitude, :longitude, :radius, :limit, :sort_by, :offset, :strict
    attr_reader :variables, :data, :client, :searches, :businesses
    def initialize(args = { latitude: 42.0307,
                            longitude: -87.8107,
                            radius: 805.0,
                            limit: 10,
                            sort_by: 'best_match',
                            offset: 0,
                            strict: true })
      self.client = self.class.create_client
      self.searches = []
      self.businesses = []
      args.each do |key, value|
        send("#{key}=", value)
      end
      self.variables = {
        latitude: latitude || 42.0307,
        longitude: longitude || -87.8107,
        radius: radius || 805.0,
        limit: limit || 10,
        sort_by: sort_by || 'best_match',
        offset: offset || 0,
        strict: strict || true
      }
    end

    def update_variables
      variables[:latitude] = latitude
      variables[:longitude] = longitude
      variables[:radius] = radius
      variables[:limit] = limit
      variables[:sort_by] = sort_by
      variables[:offset] = offset
      variables[:strict] = strict
    end

    def save_search(search)
      searches.push(search)
      searches
    end

    def clear_searches
      searches.clear
      searches
    end

    def query(query_type)
      case query_type
      when 'nearby'
        self.data = client.query(Query.nearby, variables).data
      when 'nearby_strict'
        self.data = client.query(Query.nearby_strict, variables).data
      end
      data
    end

    def get_nearby_query_data
      update_variables
      strict ? query('nearby_strict') : query('nearby')
      save_search(data.search)
      data
    end

    def searches_to_business_instances
      last_search_businesses = []
      searches.each do |search|
        search.business.each do |business|
          last_search_businesses.push(business)
        end
      end
      self.businesses = last_search_businesses.collect do |business|
        Business.find_or_create_by_id(business)
      end
      businesses
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

    attr_writer :variables, :data, :client, :searches, :businesses
  end
end
