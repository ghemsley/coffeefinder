module Coffeefinder
  class Yelp
    include Formatting
    include Queries
    attr_accessor :latitude, :longitude, :radius, :limit, :sort_by, :offset, :strict, :address, :id
    attr_reader :variables, :data, :client, :searches, :businesses
    def initialize(args = { latitude: 40.705409778017824,
                            longitude: -74.01392545907245,
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
        address: address,
        id: id
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
      variables[:id] = id
    end

    def save_search(search)
      searches.push(search) unless searches.include?(search)
      searches
    end

    def save_business(business)
      businesses.push(business) unless businesses.include?(business)
      businesses
    end

    def clear_searches
      searches.clear
      searches
    end

    def clear_businesses
      businesses.clear
      Business.all.clear
      businesses
    end

    def query(query_type)
      update_variables
      begin
        case query_type
        when 'nearby'
          self.data = client.query(nearby_query, variables).data
        when 'nearby_strict'
          self.data = client.query(nearby_strict_query, variables).data
        when 'address'
          self.data = client.query(address_query, variables).data
        when 'address_strict'
          self.data = client.query(address_strict_query, variables).data
        when 'business'
          self.data = client.query(business_query, variables).data
        end
      rescue Graphlient::Errors::ExecutionError, Graphlient::Errors::FaradayServerError
        puts separator('Please check the options you submitted to the program and run it again, or try again later.')
        puts "Something went wrong when trying to run the query '#{query_type}'."
        puts "It's possible that an invalid IP address was specified at program launch."
        puts 'You could also be getting ratelimited, or maybe Yelp is having server issues.'
        puts 'Please check the options you submitted to the program and run it again, or try again later.'
        puts separator('Please check the options you submitted to the program and run it again, or try again later.')
        exit(false)
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

    def get_business_query_data
      query('business')
      save_business(data.business)
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

    def find_business(id)
      businesses.find do |business_instance|
        business_instance.id == id
      end
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
