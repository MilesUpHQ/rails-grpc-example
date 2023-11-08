# spec/factories/products.rb
FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Commerce.material }
    price { Faker::Commerce.price(range: 0..100.0) }
    inventory_count { Faker::Number.between(from: 0, to: 100) }
    # If your product belongs to a user, add the user association
    # association :user
  end
end
