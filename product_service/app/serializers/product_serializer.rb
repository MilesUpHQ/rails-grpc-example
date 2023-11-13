# app/serializers/product_serializer.rb
class ProductSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :price, :description, :image_urls

  def image_urls
    object.images.map { |image| url_for(image) if image }
  end
end
