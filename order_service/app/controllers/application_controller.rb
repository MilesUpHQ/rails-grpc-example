# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  # before_action :authenticate_user

  private

  # Assuming you store your secret in an environment variable
  JWT_SECRET = Rails.application.credentials.secret_key_base

  def authenticate_user
    auth_header = request.headers['Authorization']
    token = auth_header.split(' ').last if auth_header

    if token.present?
      begin
        decoded_token = JWT.decode(token, JWT_SECRET, true, { algorithm: 'HS256' })
        @current_user_id = decoded_token[0]['user_id']
      rescue JWT::DecodeError => e
        render json: { errors: 'Invalid token' }, status: :unauthorized
      end
    elsif has_guest_id?
      authenticate_guest
    else
      render json: { errors: 'You must provide a token.' }, status: :forbidden
    end
  end

  def has_guest_id?
    request.headers['Guest-ID'].present? || params[:guest_id].present?
  end

  def authenticate_guest
    guest_id = request.headers['Guest-ID'] || params[:guest_id]
    # Set guest user identifier
    @current_guest_id = "#{guest_id}"
  end

end
