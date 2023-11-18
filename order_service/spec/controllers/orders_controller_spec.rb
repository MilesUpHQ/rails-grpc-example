# spec/controllers/orders_controller_spec.rb
require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  let(:user_id) { rand(1..100)}
  let(:valid_attributes) { { user_id: user_id, total_price: 50.0, status: 'pending', line_items: [{product_id: rand(1..99), quantity: 1, price: 50.0}] } }
  let(:invalid_attributes) { { user_id: nil, total_price: -10.0, status: nil } }
  let(:token) { generate_token(user_id) }
  let(:order) {create(:order)}
  let(:guest_id) { "#{SecureRandom.hex(10)}" } # Example guest ID

  # Simulate authentication
  before do |context|
    if context.metadata[:guest]
      controller.instance_variable_set(:@current_guest_id, guest_id)
    else
      allow(controller).to receive(:authenticate_user).and_return(user_id)
      controller.instance_variable_set(:@current_user_id, user_id)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: order.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do

    context 'as an authenticated user' do
      it 'creates a new order for the user' do
        # Simulate user authentication
        request.headers['Authorization'] = "Bearer #{generate_token(user_id)}"
        post :create, params: { order: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(Order.last.user_id).to eq(user_id)
      end
    end

    context 'as a guest user', :guest do
      it 'creates a new order for the guest' do
        request.headers['Guest-ID'] = guest_id
        guest_attributes = valid_attributes.except :user_id
        post :create, params: { order: guest_attributes, guest_id: guest_id }
        expect(response).to have_http_status(:created)
        expect(Order.last.guest_id).to eq(guest_id)
      end
    end

    context 'with valid params' do
      it 'creates a new Order' do
        expect {
          post :create, params: { order: valid_attributes }
        }.to change(Order, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it 'creates an order for the current user' do
        post :create, params: { order: valid_attributes }
        expect(Order.last.user_id).to eq(user_id)
      end
    end

    context 'with invalid params' do
      it 'returns a failure response' do
        post :create, params: { order: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    let(:new_attributes) { { total_price: 150.0, quantity: 3 } }
    let(:order) { create(:order) }
    let(:line_item) { create(:line_item, order: order) }
    let(:updated_order_params) {
      {
        id: order.id,
        order:
        {
          line_items_attributes:
          [{ id: order.line_items.first.id, quantity: 3 }]
        }
      }
    }

    context 'with valid params' do

      it 'updates the line item' do
        patch :update, params: updated_order_params
        expect(order.line_items.reload.first.quantity).to eq(3)
      end

      it 'updates total_price in the requested order' do
        put :update, params: updated_order_params
        order.reload
        expect(order.total_price.round).to eq(300)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      it 'returns a failure response' do
        put :update, params: { id: order.id, order: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested order' do
      order # create the order
      expect {
        delete :destroy, params: { id: order.id }
      }.to change(Order, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  # Additional tests for any custom actions like 'checkout'
end
