require 'securerandom'
class Business
  @@all = []
  attr_reader :number, :id, :name, :rating, :review_count, :distance, :price, :url, :phone, :open_now, :address, :city, :photo

  def initialize(business)
    self.id = business.id || SecureRandom.uuid
    self.name = business.name || 'Unknown'
    self.rating = business.rating || 'Unknown'
    self.review_count = business.review_count || 0
    self.distance = business.distance || 'Unknown'
    self.price = business.price || 'Unknown'
    self.url = business.url || 'Unknown'
    self.phone = business.phone || 'Unknown'
    begin
      self.open_now = business.hours.first.is_open_now || false
    rescue NoMethodError
      self.open_now = false
    end
    self.address = business.location.address1 || 'Unknown'
    self.city = business.location.city || 'Unknown'
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

  attr_writer :number, :id, :name, :rating, :review_count, :distance, :price, :url, :phone, :open_now, :address, :city, :photo
end
