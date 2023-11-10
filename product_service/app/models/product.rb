class Product < ApplicationRecord
  has_many_attached :images

  validates :name, presence: :true
  validate :image_type, if: :images_attached?
  validate :image_size, on: [:create, :update], if: :images_attached?

   # Check if images are attached for the instance.
  def images_attached?
    images.attached?
  end

  def image_urls
    images.map { |image| Rails.application.routes.url_helpers.url_for(image) }
  end

  private

  def image_type
    images.each do |image|
      if !image.content_type.in?(%('image/jpeg image/png image/gif'))
        errors.add(:images, 'Must be a JPEG, PNG, or GIF')
      end
    end
  end

  def image_size
    images.each do |image|
      image.blob.analyze
      if image.analyzed? && image.blob.byte_size > 1.megabyte
        errors.add(:images, 'is too large')
      end
    end
  end

end
