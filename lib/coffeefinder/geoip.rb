require 'coffeefinder/constants'
require 'net/http'
require 'json'

module Coffeefinder
  class GeoIP
    attr_accessor :ip_address
    attr_reader :response, :data, :status, :country_code, :country,
                :region, :region_name, :city, :zip, :latitude, :longitude
    def initialize(ip_address = '')
      self.ip_address = ip_address.to_s
      puts "Obtaining geolocation data for IP address #{self.ip_address}"
      self.response = Net::HTTP.get_response(GEOIP_API + self.ip_address)
      self.data = JSON.parse(response)
      data_to_attributes
    end

    private

    attr_writer :response, :data, :status, :country_code, :country,
                :region, :region_name, :city, :zip, :latitude, :longitude

    def data_to_attributes
      self.status = data[:status]
      self.country_code = data[:countryCode]
      self.country = data[:country]
      self.region = data[:region]
      self.region_name = data[:regionName]
      self.city = data[:city]
      self.zip = data[:zip]
      self.latitude = data[:lat]
      self.longitude = data[:lon]
    end
  end
end
