class LineItem < ApplicationRecord
  belongs_to :order

  # Callbacks to update order total price
  after_save :update_order_total_price
  after_destroy :update_order_total_price

  private

  def update_order_total_price
    total_price = order.line_items.sum { |item| item.quantity * item.price }
    order.update_column(:total_price, total_price)
  end
end
