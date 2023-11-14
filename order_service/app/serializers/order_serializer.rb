class OrderSerializer < ActiveModel::Serializer
  attributes :id, :status, :total_price, :user_id, :guest_id
  has_many :line_items
end
