# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  # Assuming you store your secret in an environment variable
  JWT_SECRET = ENV['JWT_SECRET']

  def authenticate_request
    auth_header = request.headers['Authorization']
    token = auth_header.split(' ').last if auth_header

    begin
      decoded_token = JWT.decode(token, JWT_SECRET, true, { algorithm: 'HS256' })
      @current_user_id = decoded_token[0]['user_id']
    rescue JWT::DecodeError => e
      render json: { errors: 'Invalid token' }, status: :unauthorized
    end
  end
end
