require_relative '../../config/environment'
require 'grpc'
require_relative '../rpc/product_service_services_pb'

class ProductServiceImplementation < Rpc::ProductService::Service
  def get_products(request, _unused_call)
    ids = request.ids[0].unpack('C*')
    puts "Requested IDs: #{ids.inspect}"  # Log the incoming IDs
    ActiveRecord::Base.connection_pool.with_connection do
      product_records = ::Product.where(id: ids)
      products = product_records.map do |product_record|
        Rpc::Product.new(
          id: product_record.id.to_s,
          name: product_record.name,
          description: product_record.description,
          price: product_record.price.to_f
        )
      end
      Rpc::ProductsResponse.new(products: products)
    end
  end
end
