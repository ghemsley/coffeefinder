class Business
  @@all = []
  attr_reader :number, :id, :name, :rating, :review_count, :distance, :price, :url, :phone, :open_now, :address, :city, :photo

  def initialize(business, number)
    self.number = number
    self.id = business.id if business.id
    self.name = business.name if business.name
    self.rating = business.rating if business.rating
    self.review_count = business.review_count if business.review_count
    self.distance = business.distance if business.distance
    self.price = business.price if business.price
    self.url = business.url if business.url
    self.phone = business.phone if business.phone
    self.open_now = business.hours if business.hours
    self.address = business.location.address1 if business.location.address1
    self.city = business.location.city if business.location.city
    self.class.all.push(self)
  end

  def self.all
    @@all
  end

  attr_writer :number, :id, :name, :rating, :review_count, :distance, :price, :url, :phone, :open_now, :address, :city, :photo
end
