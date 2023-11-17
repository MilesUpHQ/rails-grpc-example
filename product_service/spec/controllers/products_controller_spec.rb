# spec/controllers/products_controller_spec.rb
require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let(:valid_attributes) {
    { name: 'Sample Product', description: 'This is a sample product', price: 10.0, inventory_count: 5 }
  }
  let(:invalid_attributes) {
    { name: nil, price: -10.0 }
  }
  let(:image) { fixture_file_upload(Rails.root.join('spec/fixtures/files', 'image.jpeg'), 'image/jpeg') }
  let(:product) { create(:product, images: [image]) } # Assuming FactoryBot is set up
  let(:guest_id) { "guest_#{SecureRandom.hex(10)}" } # Example guest ID
  let(:user_id) { rand(1..100)}


  before do |context|
    unless context.metadata[:skip_before]
      allow(controller).to receive(:authenticate_user).and_return(user_id)
      controller.instance_variable_set(:@current_user_id, user_id)
      controller.instance_variable_set(:@current_guest_id, guest_id)
    end
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: product.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #details" do

    before do
      another_product = create(:product, images: [image])
      get :details, params: { product_ids: "#{product.id},#{another_product.id}" }
    end

    it "returns a success response for valid product IDs" do
      expect(response).to be_successful
    end

    it "to include image_urls [] with atleast 1 image" do
      expect(json[0]["image_urls"]).to be_present
      expect(json[0]["image_urls"].length).to be > 0
    end

  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Product" do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid params" do
      it "returns a failure response" do
        post :create, params: { product: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "without valid token", :skip_before do
      it "returns a failuer response" do
        post :create, params: { product: valid_attributes}
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) {
      { name: 'Updated Product' }
    }

    context "with valid params" do
      it "updates the requested product" do
        put :update, params: { id: product.id, product: new_attributes }
        product.reload
        expect(product.name).to eq('Updated Product')
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      it "returns a failure response" do
        put :update, params: { id: product.id, product: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested product" do
      product  # create product
      expect {
        delete :destroy, params: { id: product.id }
      }.to change(Product, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
