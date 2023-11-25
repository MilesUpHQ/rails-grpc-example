# spec/models/line_item_spec.rb
require 'rails_helper'

RSpec.describe LineItem, type: :model do

  it 'is valid with valid attributes' do
    line_item = create(:line_item)
    expect(line_item).to be_valid
  end

  describe 'callbacks' do

    let(:order) { create(:order)} # creates line_item with price 100.0
    let(:product_id) { 1 }
    # let(:line_item) { create(:line_item, order: order) }

    it 'updates order total price after save' do
      line_item = order.line_items.first
      line_item.update(quantity: 2)

      order.reload
      expected_total_price = line_item.quantity * line_item.price
      expect(order.total_price.round).to eq(expected_total_price)
    end

    it 'updates order total price after destroy' do
      line_item = LineItem.create(price: 50, quantity: 1, product_id: 1, order_id:  order.id)
      LineItem.first.destroy
      p LineItem.count
      p LineItem.last.price.round
      order.reload
      expect(order.total_price.round).to eq(50)
    end
  end

  # Add additional tests for validations and custom methods
end
