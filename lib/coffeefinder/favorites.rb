module Coffeefinder
  class Favorites
    attr_accessor :file
    attr_reader :list, :list_hash

    def initialize(path)
      self.file = FileIO.new(path)
      self.list_hash = file.read_json.transform_keys(&:to_sym) || {}
      file.hash = list_hash || {}
      self.list = if !list_hash.empty?
                    list_hash[:favorite_ids]
                  else
                    []
                  end
    end

    def save_to_list(business)
      list.push(business.id) unless list.include?(business.id)
      list_hash[:favorite_ids] = list
      file.hash = list_hash
      file.write_json
      list
    end

    def delete_from_list(id)
      Business.all.delete_if do |business|
        business.id == id
      end
      list.delete(id) if list.include?(id)
      list_hash[:favorite_ids] = list
      file.hash = list_hash
      if list.empty?
        file.delete
      else
        file.write_json
      end
      list
    end

    def clear
      list.clear
      list_hash.clear
      file.delete
      list
    end

    def save_business(id, yelp)
      business = yelp.find_business(id)
      save_to_list(business)
    end

    def build_favorite_businesses(yelp)
      list.each do |favorite_id|
        yelp.id = favorite_id
        yelp.update_variables
        yelp.get_business_query_data
      end
      businesses = yelp.businesses.collect do |business_result|
        Business.find_or_create_by_id(business_result)
      end
      businesses
    end

    def remove_favorite(id, businesses)
      delete_from_list(id)
      businesses.delete_if do |business|
        business.id == id
      end
      list
    end

    private

    attr_writer :list, :list_hash
  end
end
