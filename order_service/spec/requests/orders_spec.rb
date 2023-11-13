# spec/requests/orders_spec.rb
require 'rails_helper'

RSpec.describe "Orders", type: :request do
  let(:user_id) { rand(1..100) }
  let(:valid_attributes) { { total_price: 100.0, status: 'pending', line_items: {product_id: rand(1..100), price: 100.0, quantity: 1} } }
  let(:valid_headers) { { 'Authorization': "Bearer #{generate_token(user_id)}" } }
  let(:invalid_headers) { { 'Authorization': "Bearer 100" } }

  describe "POST /orders" do
    context "with valid parameters" do
      it "creates a new Order" do
        post orders_path, params: { order: valid_attributes }, headers: valid_headers
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      it "does not create a new order" do
        invalid_attributes = { total_price: -10.0 }
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
