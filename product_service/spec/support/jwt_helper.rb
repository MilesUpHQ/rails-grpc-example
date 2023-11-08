# spec/support/jwt_helper.rb
module JWTHelper
  JWT_SECRET = Rails.application.credentials.secret_key_base

  def self.generate_jwt_token(payload, secret = JWT_SECRET)
    JWT.encode(payload, secret, 'HS256')
  end
end
