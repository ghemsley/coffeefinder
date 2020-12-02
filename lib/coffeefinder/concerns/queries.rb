module Coffeefinder
  module Queries
    def nearby_query
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

    def nearby_strict_query
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

    def address_query
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

    def address_strict_query
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

    def business_query
      <<~GRAPHQL
        query ($id: String) {
          business(id: $id) {
            id
            name
            rating
            review_count
            distance
            price
            review_count
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
      GRAPHQL
    end
  end
end
