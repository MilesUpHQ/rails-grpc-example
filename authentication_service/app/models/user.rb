# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  # Validations
  validates :email, presence: true, uniqueness: true

  # Method to create a new token for a user
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Method to encode a token
  def self.encode_token(payload)
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  # Method to decode a token
  def self.decode_token(token)
    body = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new body
  rescue
    nil
  end
end
