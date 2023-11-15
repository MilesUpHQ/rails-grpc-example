# spec/requests/orders_spec.rb
require 'rails_helper'

RSpec.describe "Orders", type: :request do
  let(:user_id) { rand(1..100) }
  let(:guest_id) { "#{SecureRandom.hex(10)}" } # Example guest ID
  let(:valid_attributes) { { total_price: 100.0, status: 'cart', line_items: [{product_id: rand(1..100), price: 100.0, quantity: 1}] } }
  let(:valid_headers) { { 'Authorization': "Bearer #{generate_token(user_id)}" } }
  let(:invalid_headers) { { 'Authorization': "Bearer 100" } }

  describe "GET /cart" do
    context "as an authenticated user" do
      it "returns the current user's cart" do
        # Create a cart for the user
        create(:order, user_id: user_id, status: 'cart')
        # Simulate user authentication
        get '/orders/cart', headers: valid_headers
        expect(response).to have_http_status(:ok)
        expect(json_response['user_id']).to eq(user_id)
      end
    end

    context "as a guest user" do
      it "returns the guest's cart" do
        # Create a cart for the guest
        create(:order, guest_id: guest_id, status: 'cart')
        # Simulate guest access
        get '/orders/cart', params: {guest_id: guest_id}, headers: { 'guest_id' => guest_id }
        expect(response).to have_http_status(:ok)
        expect(json_response['guest_id']).to eq(guest_id)
      end
    end
  end

  describe "POST /orders" do
    context "with valid parameters" do
      it "creates a new Order" do
        post orders_path, params: { order: valid_attributes }, headers: valid_headers
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      it "does not create a new order" do
        invalid_attributes = { total_price: -10.0, line_items: [] }
        post orders_path, params: { order: invalid_attributes }, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end


    context "without authentication" do
      it "does not allow creating orders" do
        post orders_path, params: { order: valid_attributes }, headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

  end

  describe "PUT /orders/:id" do
    let(:order) { create(:order) }

    context "with valid parameters" do
      let(:new_attributes) { { status: 'completed' } }

      it "updates the requested order" do
        put order_path(order), params: { order: new_attributes }, headers: valid_headers
        order.reload
        expect(order.status).to eq('completed')
      end
    end
  end

  describe "DELETE /cart/remove_item/:line_item_id" do
    let(:order) { create(:order, user_id: user_id) }
    let(:line_item) { create(:line_item, order: order) }

    it "removes the item from the cart" do
      delete "/orders/remove/#{line_item.id}", params: { order_id: order.id }, headers: valid_headers
      order.reload
      expect(response).to have_http_status(:ok)
      expect(order.line_items).not_to include(line_item)
    end

    it "returns not found if the item does not exist" do
      delete "/orders/remove/999", params: { order_id: order.id }, headers: valid_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /orders/:id" do
    it "deletes the order" do
      order = create(:order)
      expect {
        delete order_path(order), headers: valid_headers
      }.to change(Order, :count).by(-1)
    end
end

  # ...
end
