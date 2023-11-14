# spec/controllers/orders_controller_spec.rb
require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  let(:user_id) { rand(1..100)}
  let(:valid_attributes) { { user_id: user_id, total_price: 50.0, status: 'pending', line_items: {product_id: rand(1..99), quantity: 1, price: 50.0} } }
  let(:invalid_attributes) { { user_id: nil, total_price: -10.0, status: nil } }
  let(:token) { generate_token(user_id) }
  let(:order) {create(:order)}
  let(:guest_id) { "guest_#{SecureRandom.hex(10)}" } # Example guest ID

  # Simulate authentication
  before do
    allow(controller).to receive(:authenticate_user).and_return(user_id)
    controller.instance_variable_set(:@current_user_id, user_id)
    controller.instance_variable_set(:@current_guest_id, guest_id)
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

    context 'as a guest user' do
      it 'creates a new order for the guest' do
        request.headers['Guest-ID'] = guest_id
        post :create, params: { order: valid_attributes, guest_id: guest_id }
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
    let(:new_attributes) { { total_price: 100.0 } }

    context 'with valid params' do
      it 'updates the requested order' do
        put :update, params: { id: order.id, order: new_attributes }
        order.reload
        expect(order.total_price).to eq(100.0)
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
