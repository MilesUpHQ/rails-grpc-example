# spec/models/order_spec.rb
require 'rails_helper'

RSpec.describe Order, type: :model do
  it 'is valid with valid attributes' do
    user_id = rand(1..100) # Assuming you have a user factory
    order = create(:order)
    expect(order).to be_valid
  end

  it 'is not valid without a total_price' do
    order = Order.new(total_price: nil)
    expect(order).not_to be_valid
  end

  # Add tests for associations, methods, and any custom logic
end
