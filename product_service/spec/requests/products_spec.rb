# spec/requests/products_spec.rb
require 'rails_helper'

RSpec.describe 'Products', type: :request do
  # Mock the token verification process
  let(:user_id) { 1 } # Use a fixed user ID for testing
  # let(:jwt_secret) { 'test_secret' }
  let(:token) { JWTHelper.generate_jwt_token({ user_id: user_id }) }
  let(:image) { fixture_file_upload(Rails.root.join('spec/fixtures/files', 'image.jpeg'), 'image/jpeg') }
  let(:valid_headers) {
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{token}"
    }
  }

  let(:non_authorized_headers) {
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer 123"
    }
  }

  describe 'POST /products' do
    let(:valid_attributes) { { name: 'New Product', description: 'Great product', price: 29.99, inventory_count: 10 } }

    context 'with valid token' do
      it 'creates a new product' do
        post '/products', params: valid_attributes.to_json, headers: valid_headers
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid token' do
      it 'does not create a new product' do
        post '/products', params: valid_attributes.to_json, headers: { 'Authorization' => 'Bearer invalid_token' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'without token' do
      it 'does not create a new product' do
        post '/products', params: valid_attributes.to_json
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid data' do
      it 'does not create a product' do
        post '/products', params: { name: '' }.to_json, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to have_key('errors')
      end
    end


  end

  describe 'POST /products with images' do
    let(:valid_attributes) do
      {
        name: 'New Product',
        description: 'Great product',
        price: 29.99,
        inventory_count: 10
      }
    end

    let(:large_image) { fixture_file_upload(Rails.root.join('spec/fixtures/files', 'large_image.jpg'), 'image/jpeg') }
    let(:valid_image) { generate_test_image }
    let(:invalid_image) { generate_test_image(name: 'test_file.txt', content_type: 'text/plain') }
    let(:oversized_image) { generate_test_image(size: 3.megabytes)}


    context 'with valid parameters and images' do
      it 'creates a new product and attaches images' do
        expect {
          post products_path, params: { product: valid_attributes.merge(images: [image]) }, headers: valid_headers.merge('Content-Type': 'multipart/form-data')
        }.to change(Product, :count).by(1)
        .and change(ActiveStorage::Attachment, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        # Parse the response body to confirm image data is present
        json_response = JSON.parse(response.body)
        expect(json_response['images']).to be_present
        expect(Product.last.images).to be_attached
        # expect(Product.last.images.first.blob.byte_size).to be > 0
      end

      it 'rejects non-image files' do
        post products_path, params: { product: valid_attributes.merge(images: [invalid_image]) }, headers: valid_headers.merge('Content-Type': 'multipart/form-data')

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']['images']).to include('Must be a JPEG, PNG, or GIF')
      end

      it 'rejects files that are too large' do
        # oversized_image = generate_test_image(size: 3.megabytes)
        post products_path, params: { product: valid_attributes.merge(images: [large_image]) }, headers: valid_headers.merge('Content-Type': 'multipart/form-data')

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']['images']).to include('is too large (should be at most 3 MB)')
      end
    end
  end

  describe 'GET /products' do
    it 'retrieves a list of products' do
      get '/products', headers: headers
      expect(response).to have_http_status(:ok)
      expect(json).to be_an_instance_of(Array)
    end
  end

  describe 'GET /products/:id' do
    let(:product) { create(:product, images: [image]) }

    it 'retrieves a specific product with images' do
      get "/products/#{product.id}", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(json['id']).to eq(product.id)
      p json
      expect(json['image_urls']).to be_present
    end

    context 'when product does not exist' do
      it 'returns a not found status' do
        get "/products/non_existing_id", headers: valid_headers
        expect(response).to have_http_status(:not_found)
      end
    end

  end

  describe 'PUT /products/:id' do
    let(:product) { create(:product) }
    let(:new_attributes) { { name: 'Updated Product' } }

    context 'with valid token and data' do
      it 'updates the product' do
        put "/products/#{product.id}", params: new_attributes.to_json, headers: valid_headers
        product.reload
        expect(response).to have_http_status(:ok)
        expect(product.name).to eq('Updated Product')
      end

      it 'returns a not found status when the product does not exist' do
        put "/products/non_existent_id", params: new_attributes.to_json, headers: valid_headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /products/:id' do
    let!(:product) { create(:product) }

    it 'deletes a product' do
      expect {
        delete "/products/#{product.id}", headers: valid_headers
      }.to change(Product, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns a not found status when the product does not exist' do
      non_existent_id = Product.last.id + 1
      delete "/products/#{non_existent_id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end

    context 'with non-authorized user' do
      it 'does not allow the user to delete a product' do
        delete "/products/#{product.id}", headers: non_authorized_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

  end

end
