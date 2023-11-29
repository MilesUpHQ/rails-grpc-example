require 'grpc'
require_relative '../rpc/product_service_services_pb'

class ProductServiceClient
  def initialize
    @stub = Rpc::ProductService::Stub.new('localhost:50051', :this_channel_is_insecure)
  end

  def get_products(ids)
    request = Rpc::ProductsRequest.new(ids: ids)
    response = @stub.get_products(request)
    p response
    rescue GRPC::BadStatus => e
      puts e.to_s
      nil
  end
end
