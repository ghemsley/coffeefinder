module Coffeefinder
  class Query
    def self.nearby
      <<~GRAPHQL
        query ($latitude: Float, $longitude: Float, $radius: Float, $limit: Int, $sort_by: String, $offset: Int) {
          search(term: "coffee", latitude: $latitude, longitude: $longitude, radius: $radius, limit: $limit, sort_by: $sort_by, offset: $offset) {
            total
            business {
              id
              name
              rating
              review_count
              distance
              price
              url
              phone
              hours {
                is_open_now
              }
              location {
                address1
                city
              }
            }
          }
        }
      GRAPHQL
    end

    def self.nearby_strict
      <<~GRAPHQL
        query ($latitude: Float, $longitude: Float, $radius: Float, $limit: Int, $sort_by: String, $offset: Int) {
          search(categories: "coffee", latitude: $latitude, longitude: $longitude, radius: $radius, limit: $limit, sort_by: $sort_by, offset: $offset) {
            total
            business {
              id
              name
              rating
              review_count
              distance
              price
              url
              phone
              hours {
                is_open_now
              }
              location {
                address1
                city
              }
            }
          }
        }
      GRAPHQL
    end

    def self.address
      <<~GRAPHQL
        query ($address: String, $radius: Float, $limit: Int, $sort_by: String, $offset: Int) {
          search(term: "coffee", location: $address, radius: $radius, limit: $limit, sort_by: $sort_by, offset: $offset) {
            total
            business {
              id
              name
              rating
              review_count
              distance
              price
              url
              phone
              hours {
                is_open_now
              }
              location {
                address1
                city
              }
            }
          }
        }
      GRAPHQL
    end

    def self.address_strict
      <<~GRAPHQL
        query ($address: String, $radius: Float, $limit: Int, $sort_by: String, $offset: Int) {
          search(categories: "coffee", location: $address, radius: $radius, limit: $limit, sort_by: $sort_by, offset: $offset) {
            total
            business {
              id
              name
              rating
              review_count
              distance
              price
              url
              phone
              hours {
                is_open_now
              }
              location {
                address1
                city
              }
            }
          }
        }
      GRAPHQL
    end
  end
end
