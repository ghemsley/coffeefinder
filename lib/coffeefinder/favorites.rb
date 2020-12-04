module Coffeefinder
  class Favorites
    attr_accessor :file
    attr_reader :list, :list_hash

    def initialize(path)
      self.file = FileIO.new(path)
      self.list_hash = file.read_json.transform_keys(&:to_sym) || {}
      file.hash = list_hash || {}
      self.list = if !list_hash.empty?
                    list_hash[:favorites_array]
                  else
                    []
                  end
    end

    def save_to_list(business)
      list.push(business.id) unless list.include?(business.id)
      list_hash[:favorites_array] = list
      file.hash = list_hash
      file.write_json
    end

    def delete_from_list(id)
      Business.all.delete_if do |business|
        business.id == id
      end
      list.delete(id) if list.include?(id)
      list_hash[:favorites_array] = list
      file.hash = list_hash
      if list.empty?
        file.delete
      else
        file.write_json
      end
    end

    def clear
      list.clear
      list_hash.clear
      file.delete
    end

    private

    attr_writer :list, :list_hash
  end
end
