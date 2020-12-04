module Coffeefinder
  class Business
    @@all = []
    attr_reader :number, :id, :name, :rating, :review_count, :distance, :price, :url, :phone, :open_now, :address, :city

    def initialize(business)
      self.id = business.id || SecureRandom.uuid
      self.name = business.name || 'Unknown'.colorize(:light_red)
      self.rating = business.rating || 'Unknown'.colorize(:light_red)
      self.review_count = business.review_count || 0
      self.distance = business.distance || 0.0
      self.price = business.price.to_s.colorize(:light_green) || 'Unknown'.colorize(:light_red)
      self.url = business.url || 'Unknown'.colorize(:light_red)
      self.phone = business.phone || 'Unknown'.colorize(:light_red)
      begin
        self.open_now = business.hours.first.is_open_now
      rescue NoMethodError
        self.open_now = false
      end
      self.address = business.location.address1 || 'Unknown'.colorize(:light_red)
      self.city = business.location.city || 'Unknown'.colorize(:light_red)
      self.class.all.push(self)
    end

    def self.find_or_create_by_id(business)
      all.find do |existing_business|
        existing_business.id == business.id
      end || new(business)
    end

    def self.all
      @@all
    end

    attr_writer :number, :id, :name, :rating, :review_count, :distance, :price, :url, :phone, :open_now, :address, :city
  end
end
