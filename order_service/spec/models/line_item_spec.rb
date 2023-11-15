# spec/models/line_item_spec.rb
require 'rails_helper'

RSpec.describe LineItem, type: :model do

  it 'is valid with valid attributes' do
    line_item = create(:line_item)
    expect(line_item).to be_valid
  end

  describe 'callbacks' do
    let(:order) { create(:order) }
    let(:product_id) { 1 }
    let(:line_item) { create(:line_item, order: order) }

    it 'updates order total price after save' do
      line_item = create(:line_item, order: order, product_id: 1, quantity: 2)

      order.reload
      expected_total_price = line_item.quantity * line_item.price
      expect(order.total_price).to eq(expected_total_price)
    end

    it 'updates order total price after destroy' do
      line_item = create(:line_item, order: order, product_id: 1, quantity: 2)
      line_item.destroy

      order.reload
      expect(order.total_price.round).to eq(0)
    end
  end

  # Add additional tests for validations and custom methods
end
