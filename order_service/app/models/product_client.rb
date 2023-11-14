class ProductClient < ApplicationRecord
  PRODUCT_SERVICE_URL = 'http://localhost:3001/products/details'

def self.fetch_details(product_ids)
    response = HTTParty.get("#{PRODUCT_SERVICE_URL}?product_ids=#{product_ids.join(',')}")
    if response.success?
      response.parsed_response
    else
      {} # Handle error or return an empty hash
    end
  end

end