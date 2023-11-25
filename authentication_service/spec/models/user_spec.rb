require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
    end

    it 'is not valid without password_confirmation' do
      user = build(:user, email: 'test@example.com', password: 'password123')
      expect(user).not_to be_valid
    end
  end

  describe 'token methods' do
    let(:user) { create(:user) }

    it 'generates a new token' do
      token = User.new_token
      expect(token).not_to be_nil
    end

    it 'encodes and decodes a token' do
      payload = { user_id: user.id }
      token = User.encode_token(payload)
      expect(token).not_to be_nil

      decoded_payload = User.decode_token(token)
      expect(decoded_payload['user_id']).to eq(user.id)
    end
  end

end
