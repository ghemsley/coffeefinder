module Coffeefinder
  class Query
    def self.nearby
      <<~GRAPHQL
        query ($latitude: Float, $longitude: Float, $radius: Float, $limit: Int, $sort_by: String) {
          search(term: "coffee", latitude: $latitude, longitude: $longitude, radius: $radius, limit: $limit, sort_by: $sort_by) {
            total
            business {
              name
              rating
              review_count
              location {
                address1
                city
                state
                country
              }
            }
          }
        }
      GRAPHQL
    end
  end
end
