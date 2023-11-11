class Product < ApplicationRecord
  has_many_attached :images

  validates :name, presence: :true
  validate :image_type, if: :images_attached?
  validate :image_size, on: [:create, :update], if: :images_attached?
  # validates :images, presence: :true, blob: { size_range: 1..(2.megabytes) }, if: :images_attached?

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
      if image.analyzed? && image.blob.byte_size > 3.megabyte
        errors.add(:images, 'is too large (should be at most 3 MB)')
      end
    end
  end

end
