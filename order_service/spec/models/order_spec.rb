# spec/models/order_spec.rb
require 'rails_helper'

RSpec.describe Order, type: :model do
  it 'is valid with valid attributes' do
    order = create(:order)
    expect(order).to be_valid
  end

  it 'is not valid without a total_price' do
    order = Order.new(total_price: nil, status: "cart", user_id: 1)
    order.line_items.build(product_id: 1, quantity: 1, price: 10)
    expect(order).not_to be_valid
    expect(order.errors).to include("total_price")
    expect(order.errors.messages[:total_price]).to include("can't be blank")
  end

  it 'is not valid when total_price is not a number' do
    order = Order.new(total_price: "two", status: "cart", user_id: 1)
    order.line_items.build(product_id: 1, quantity: 1, price: 10)
    expect(order).not_to be_valid
    expect(order.errors.messages[:total_price]).to include("is not a number")
  end

  it 'is not valid without a status' do
    order = Order.new(status: "", total_price: 10, user_id: 1)
    order.line_items.build(product_id: 1, quantity: 1, price: 10)
    expect(order).not_to be_valid
    expect(order.errors).to include("status")
  end

  describe "validation" do
    it { should validate_presence_of(:total_price) }
    it { should validate_presence_of(:status)}
  end

  describe 'associations' do
    it { should have_many(:line_items) }
  end

  # Add tests for associations, methods, and any custom logic
end
