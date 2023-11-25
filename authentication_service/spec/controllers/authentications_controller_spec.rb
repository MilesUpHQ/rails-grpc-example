require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do

  describe 'POST #register' do
  let(:valid_attributes) {
    {
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    }
  }
  let(:invalid_attributes) {
    {
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'wrong'
    }
  }

  context 'with valid params' do
    it 'creates a new User' do
      expect {
        post :register, params: valid_attributes
      }.to change(User, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(json['user']['email']).to eq('test@example.com')
      expect(json['token']).to be_present
    end
  end

  context 'with invalid params' do
    it 'returns a failure response' do
      post :register, params: invalid_attributes
      expect(response).to have_http_status(:unprocessable_entity)
      expect_error_to_be_present
    end

    it 'returns a failure response when fields are blank' do
      post :register, params: {email: "", password: "", password_confirmation: ""}
      expect(response).to have_http_status(:unprocessable_entity)
      expect_error_to_be_present
      expect_email_error_message
      expect(json['error']).to include("Password can't be blank")
    end

    it 'returns a failure response when password is empty' do
      post :register, params: {email: "magesh@example.net", password: ""}
      expect(response).to have_http_status(:unprocessable_entity)
      expect_error_to_be_present
      expect(json['error']).not_to include("Email can't be blank")
      expect(json['error']).to include("Password can't be blank")
    end
  end
end

describe 'POST #login' do
  let(:user) { create(:user, email: 'user@example.com', password: 'password') }

  context 'with valid credentials' do
    it 'logs in the user' do
      post :login, params: { email: user.email, password: 'password' }
      expect(response).to have_http_status(:ok)
      expect(json['token']).to be_present
    end
  end

  context 'with invalid credentials' do
    it 'returns an unauthorized response' do
      post :login, params: { email: user.email, password: 'wrongpassword' }
      expect(response).to have_http_status(:unauthorized)
      expect(json['error']).to eq('Invalid email or password')
    end
  end
end

end