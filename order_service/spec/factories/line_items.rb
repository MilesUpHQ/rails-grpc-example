# spec/factories/line_items.rb
FactoryBot.define do
  factory :line_item do
    order # Assuming an order factory is available
    product_id {rand(1..100)} # Assuming a product factory is available
    quantity { Faker::Number.between(from: 1, to: 10) }
    price { Faker::Commerce.price(range: 1..20.0) }
  end
end
