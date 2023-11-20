class ProductClient < ApplicationRecord
  PRODUCT_SERVICE_URL = 'http://localhost:3001/products/details'

  def self.fetch_details(product_ids)
    response = HTTParty.get("#{PRODUCT_SERVICE_URL}?product_ids=#{product_ids.join(',')}")
    if response.success?
      response.parsed_response
    else
      handle_error_response(response)
    end
  end

  def self.handle_error_response(response)
    # Log the error, notify a monitoring service, or implement retry logic
    Rails.logger.error "Product service responded with #{response.code}: #{response.message}"
    {}
  end

end