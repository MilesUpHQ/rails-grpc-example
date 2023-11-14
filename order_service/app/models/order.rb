class Order < ApplicationRecord

  has_many :line_items, dependent: :destroy


  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[cart pending completed cancelled] }

  def line_items_with_product_details
    product_ids = line_items.pluck(:product_id).uniq
    products_info = ProductClient.fetch_details(product_ids)
    p products_info

    line_items.map do |item|
      item_attributes = item.attributes
      product_details = products_info.select{|product| product["id"] == item.product_id} || {}
      p item_attributes
      p product_details[0]
      item_attributes.merge(product_details[0])
    end
  end
end
