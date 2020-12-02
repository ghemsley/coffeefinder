module Coffeefinder
  class Table
    include Formatting
    attr_reader :options
    def initialize(options)
      self.options = options
    end

    def search_result_table(yelp, iteration_count)
      table = TTY::Table.new(
        header: ['Number', 'Name', sort_by_string(options[:sort_by])]
      )
      yelp_results = yelp.data.search.business.collect { |yelp_business| yelp_business }
      yelp_results.sort_by!(&:distance) if options[:sort_by] == 'distance'
      yelp_results.each do |yelp_business|
        business = Business.find_or_create_by_id(yelp_business)
        business.number = iteration_count + 1
        table << case options[:sort_by]
                 when 'best_match'
                   { 'Number' => (iteration_count + 1),
                     'Name' => business.name,
                     'Rating' => "#{business.rating} stars" }
                 when 'distance'
                   { 'Number' => (iteration_count + 1),
                     'Name' => business.name,
                     'Distance' => meters_to_miles(business.distance) }
                 when 'rating'
                   { 'Number' => (iteration_count + 1),
                     'Name' => business.name,
                     'Rating' => "#{business.rating} stars" }
                 when 'review_count'
                   { 'Number' => (iteration_count + 1),
                     'Name' => business.name,
                     'Reviews' => "#{business.review_count} reviews" }
                 else
                   { 'Number' => (iteration_count + 1),
                     'Name' => business.name,
                     'Rating' => "#{business.rating} stars" }
                 end
        iteration_count += 1
      end
      puts table.render(
        :unicode,
        alignments: %i[center left left]
      )
      iteration_count
    end

    def business_table(business)
      table = TTY::Table.new(
        header: %w[Attribute Value]
      )
      table << { 'Atribute' => 'Name', 'Value' => business.name }
      table << { 'Atribute' => 'Rating', 'Value' => business.rating }
      table << { 'Atribute' => 'Reviews', 'Value' => business.review_count }
      table << { 'Atribute' => 'Distance', 'Value' => business.distance.zero? ? 'Unknown' : meters_to_miles(business.distance) }
      table << { 'Atribute' => 'Price', 'Value' => business.price }
      table << { 'Atribute' => 'Address', 'Value' => business.address }
      table << { 'Atribute' => 'City', 'Value' => business.city }
      table << { 'Atribute' => 'Open now', 'Value' => business.open_now ? 'Yes' : 'No' }
      puts table.render(
        :unicode,
        alignments: %i[left left]
      )
    end
    attr_writer :options
  end
end
