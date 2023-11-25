# spec/requests/authentication_spec.rb
require 'rails_helper'

RSpec.describe "Authentications", type: :request do
  describe "POST /register" do
    let(:valid_attributes) do
      {
        email: 'user@example.com',
        password: 'password',
        password_confirmation: 'password'
      }
    end

    let(:invalid_attributes) do
      {
        email: 'user@example.com',
        password: 'password',
        password_confirmation: 'wrong'
      }
    end

    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post '/register', params: valid_attributes
        }.to change(User, :count).by(1)
      end

      it "returns a JWT token" do
        post '/register', params: valid_attributes
        expect(response).to have_http_status(:created)
        expect(json['token']).not_to be_nil
      end

      it "returns a success message" do
        post '/register', params: valid_attributes
        expect(json['message']).to eq('User created successfully')
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post '/register', params: invalid_attributes
        }.to change(User, :count).by(0)
      end

      it "returns an error message" do
        post '/register', params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['error']).to include("Password confirmation doesn't match Password")
      end
    end

    context "email already taken" do
      before { create(:user, email: 'user@example.com') }

      let(:user_params) do
        {
          email: 'user@example.com',
          password: 'password',
          password_confirmation: 'password'
        }
      end

      it "returns a bad request status" do
        post '/register', params: user_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['error']).to include('Email has already been taken')
      end
    end
  end

  describe "POST /login" do
    let(:user) { FactoryBot.create(:user, email: 'user@example.com', password: 'password') }

    context "with valid credentials" do
      before do
        post '/login', params: { email: user.email, password: user.password }
      end

      it "logs in the user and returns a success status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns a JWT token" do
        expect(json['token']).not_to be_nil
      end

      it 'expect a valid token' do
        decoded_token = User.decode_token(json['token'])
        expect(decoded_token).not_to be_nil
        expect(decoded_token['user_id']).to eq(user.id)
      end
    end

    context "with invalid credentials" do
      it "returns an error message and unauthorized status" do
        post '/login', params: { email: user.email, password: 'wrong' }
        expect(response).to have_http_status(:unauthorized)
        expect(json['error']).to include('Invalid email or password')
      end
    end
  end

end
