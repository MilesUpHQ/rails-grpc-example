# spec/factories/orders.rb
FactoryBot.define do
  factory :order do
    user_id {rand(1..100)} # Assuming you have a user factory
    guest_id {"#{SecureRandom.hex(10)}"}
    total_price { 0.0 }
    status { "cart" } # Or whatever default status you wish to use
  end
end
