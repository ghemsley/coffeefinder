require_relative './concerns/constants'
require_relative './concerns/queries'
require_relative './secrets'
require 'graphlient'

module Coffeefinder
  class Yelp
    include Coffeefinder::Queries
    attr_accessor :latitude, :longitude, :radius, :limit, :sort_by, :offset, :strict, :address
    attr_reader :variables, :data, :client, :searches, :businesses
    def initialize(args = { latitude: nil,
                            longitude: nil,
                            radius: DEFAULT_RADIUS,
                            limit: DEFAULT_LIMIT,
                            sort_by: DEFAULT_SORT })
      self.client = self.class.create_client
      self.offset = 0
      self.strict = true
      self.address = DEFAULT_ADDRESS
      self.searches = []
      self.businesses = []
      args.each do |key, value|
        send("#{key}=", value)
      end
      self.variables = {
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        limit: limit,
        sort_by: sort_by,
        offset: offset,
        strict: strict,
        address: address
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
      variables[:address] = address
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
      update_variables
      case query_type
      when 'nearby'
        self.data = client.query(nearby_query, variables).data
      when 'nearby_strict'
        self.data = client.query(nearby_strict_query, variables).data
      when 'address'
        self.data = client.query(address_query, variables).data
      when 'address_strict'
        self.data = client.query(address_strict_query, variables).data
      end
      data
    end

    def get_nearby_query_data
      strict ? query('nearby_strict') : query('nearby')
      save_search(data.search)
      data
    end

    def get_address_query_data
      strict ? query('address_strict') : query('address')
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
