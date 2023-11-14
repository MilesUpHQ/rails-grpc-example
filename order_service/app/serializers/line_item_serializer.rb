class LineItemSerializer < ActiveModel::Serializer
  attributes :id, :product_id, :quantity, :price
end
