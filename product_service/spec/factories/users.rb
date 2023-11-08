# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'testpassword' }
    password_confirmation { 'testpassword' }
    # Add other necessary user attributes here
  end
end
