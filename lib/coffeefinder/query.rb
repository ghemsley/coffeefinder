module Coffeefinder
  class Query
    def self.nearby
      <<~GRAPHQL
        query ($latitude: Float, $longitude: Float, $radius: Float) {
          search(term: "coffee", latitude: $latitude, longitude: $longitude, radius: $radius) {
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
