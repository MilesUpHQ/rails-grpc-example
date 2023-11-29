# require 'grpc'
# require_relative './product_service_services_pb'

# require 'active_record'
# require 'yaml'

# Assuming you have a database configuration file similar to Rails (config/database.yml)
# ENV['RAILS_ENV'] ||= 'development'
# current_directory = File.dirname(__FILE__)
# db_config_path = File.join('..', '..', 'config', 'database.yml')
# db_config_contents = File.read("../../config/database.yml")
# db_config = YAML.safe_load(db_config_path, aliases: true)

# ActiveRecord::Base.establish_connection(db_config['development'])  # Or another environment

# Require your models after establishing the connection
# require_relative '../models/product'
require_relative '../rpc/product_service_implementation'


# Run the gRPC server to listen for requests from clients
def run
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
  s.handle(ProductServiceImplementation)
  puts '... running insecurely on 0.0.0.0:50051'
  s.run_till_terminated
end

run
