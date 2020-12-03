module Coffeefinder
  class Table
    include Formatting
    attr_reader :options
    def initialize(options)
      self.options = options
    end

    def search_result_table(yelp, iteration_count)
      table = TTY::Table.new(
        header: ['Number'.colorize(:light_green), 'Name'.colorize(:light_green), sort_by_string(options[:sort_by]).colorize(:light_green)]
      )
      yelp_results = yelp.data.search.business.collect { |yelp_business| yelp_business }
      yelp_results.sort_by!(&:distance) if options[:sort_by] == 'distance'
      yelp_results.each do |yelp_business|
        business = Business.find_or_create_by_id(yelp_business)
        business.number = iteration_count + 1
        table << case options[:sort_by]
                 when 'best_match'
                   { 'Number' => (iteration_count + 1).to_s.colorize(:light_blue),
                     'Name' => business.name.to_s.colorize(:light_white),
                     'Rating' => "#{business.rating.to_s.colorize(:light_yellow)} stars" }
                 when 'distance'
                   { 'Number' => (iteration_count + 1).to_s.colorize(:light_blue),
                     'Name' => business.name.to_s.colorize(:light_white),
                     'Distance' => meters_to_miles(business.distance).colorize(:light_white) }
                 when 'rating'
                   { 'Number' => (iteration_count + 1).to_s.colorize(:light_blue),
                     'Name' => business.name.to_s.colorize(:light_white),
                     'Rating' => "#{business.rating.to_s.colorize(:light_yellow)} stars" }
                 when 'review_count'
                   { 'Number' => (iteration_count + 1).to_s.colorize(:light_blue),
                     'Name' => business.name.to_s.colorize(:light_white),
                     'Reviews' => "#{business.review_count} reviews".colorize(:light_white) }
                 else
                   { 'Number' => (iteration_count + 1).to_s.colorize(:light_blue),
                     'Name' => business.name.colorize(:light_white),
                     'Rating' => "#{business.rating.to_s.colorize(:light_yellow)} stars" }
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
        header: ['Attribute'.colorize(:light_green), 'Value'.colorize(:light_green)]
      )
      table << { 'Atribute' => 'Name'.colorize(:light_blue), 'Value' => business.name }
      table << { 'Atribute' => 'Rating'.colorize(:light_blue), 'Value' => "#{business.rating.to_s.colorize(:light_yellow)} stars" }
      table << { 'Atribute' => 'Reviews'.colorize(:light_blue), 'Value' => business.review_count }
      table << { 'Atribute' => 'Distance'.colorize(:light_blue), 'Value' => business.distance.zero? ? 'Unknown'.colorize(:light_red) : meters_to_miles(business.distance).colorize(:light_white) }
      table << { 'Atribute' => 'Price'.colorize(:light_blue), 'Value' => business.price }
      table << { 'Atribute' => 'Address'.colorize(:light_blue), 'Value' => business.address }
      table << { 'Atribute' => 'City'.colorize(:light_blue), 'Value' => business.city }
      table << { 'Atribute' => 'Open now'.colorize(:light_blue), 'Value' => business.open_now ? 'Yes'.colorize(:light_green) : 'No'.colorize(:light_red) }
      puts table.render(
        :unicode,
        alignments: %i[left left]
      )
    end
    attr_writer :options
  end
end
