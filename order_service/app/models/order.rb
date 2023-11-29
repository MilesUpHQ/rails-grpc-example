class Order < ApplicationRecord

  has_many :line_items, dependent: :destroy

  accepts_nested_attributes_for :line_items


  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[cart pending completed cancelled] }
  validate :must_have_at_least_one_line_item

  def must_have_at_least_one_line_item
    errors.add(:base, 'Order must have at least one line item') if !line_items.present?
  end

  def line_items_with_product_details
    product_ids = line_items.pluck(:product_id).uniq
    # products_info = ProductClient.fetch_details(product_ids)
    client = ProductServiceClient.new
    products = client.get_products(product_ids)
    p products

    # line_items.map do |item|
    #   item_attributes = item.attributes
    #   product_details = products_info.select{|product| product["id"] == item.product_id}.first || {}
    #   product_details["product_id"] = product_details["id"]
    #   product_details.delete("id")
    #   item_attributes.merge(product_details)
    # end
  end

  def get_products
    client = ProductServiceClient.new
    products = client.get_products([1,2])
    p products
  end

end
