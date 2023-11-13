# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  # before_action :authenticate_user

  private

  # Assuming you store your secret in an environment variable
  JWT_SECRET = Rails.application.credentials.secret_key_base

  def authenticate_user
    auth_header = request.headers['Authorization']
    p "auth" + auth_header
    token = auth_header.split(' ').last if auth_header

    if token.blank? || token.nil?
      render json: { errors: 'You must provide a token.' }, status: :forbidden
    else
      begin
        decoded_token = JWT.decode(token, JWT_SECRET, true, { algorithm: 'HS256' })
        @current_user_id = decoded_token[0]['user_id']
      rescue JWT::DecodeError => e
        render json: { errors: 'Invalid token' }, status: :unauthorized
      end
    end
  end
end
