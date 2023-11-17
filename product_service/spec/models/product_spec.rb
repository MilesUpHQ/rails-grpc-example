# spec/models/product_spec.rb
require 'rails_helper'

RSpec.describe Product, type: :model do
  # Sample valid attributes
  let(:valid_attributes) {
    { name: 'Sample Product', description: 'This is a sample product', price: 10.0, inventory_count: 5 }
  }

  # Sample image for testing
  let(:image) {
    fixture_file_upload(Rails.root.join('spec/fixtures/files', 'image.jpeg'), 'image/jpeg')
  }

  describe 'validations' do
    it 'is valid with valid attributes' do
      product = Product.new(valid_attributes)
      expect(product).to be_valid
    end

    it 'is not valid without a name' do
      product = Product.new(valid_attributes.except(:name))
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end

    context 'when images are attached' do
      it 'is valid with valid image types' do
        product = Product.new(valid_attributes)
        product.images.attach(image)
        expect(product).to be_valid
      end

      it 'is not valid with invalid image types' do
        invalid_image = generate_test_image(name: 'test_file.txt', content_type: 'text/plain')
        product = Product.new(valid_attributes)
        product.images.attach(invalid_image)
        product.save
        expect(product).not_to be_valid
        expect(product.errors[:images]).to include('Must be a JPEG, PNG, or GIF')
      end

      it 'is not valid if an image is too large' do
        # Assuming you have a way to create or mock an oversized image
        large_image = generate_test_image(size: 5.megabytes) # Replace with your method to mock a large image
        product = Product.new(valid_attributes)
        product.images.attach(large_image)
        expect(product).not_to be_valid
        expect(product.errors[:images]).to include('is too large (should be at most 3 MB)')
      end
    end
  end

  describe '#images_attached?' do
    it 'returns true when images are attached' do
      product = Product.new(valid_attributes)
      product.images.attach(image)
      expect(product.images_attached?).to be true
    end

    it 'returns false when no images are attached' do
      product = Product.new(valid_attributes)
      expect(product.images_attached?).to be false
    end
  end

  describe '#image_urls' do
    it 'returns a list of URLs for attached images' do
      product = Product.new(valid_attributes)
      product.images.attach(image)
      product.save
      expect(product.image_urls).to all(be_a(String))
    end
  end
end
