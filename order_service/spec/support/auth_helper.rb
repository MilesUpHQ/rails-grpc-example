# spec/support/auth_helper.rb
module AuthHelper
  def generate_token(user_id)
    payload = { user_id: user_id }
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :controller
end
