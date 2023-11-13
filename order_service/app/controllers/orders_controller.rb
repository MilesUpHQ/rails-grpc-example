class OrdersController < ApplicationController
  before_action :authenticate_user, only: [:create, :update]
  before_action :set_order, only: [:show, :update, :destroy, :checkout]

  # POST /orders
  # This will create a new order, acting as a cart initially
  def create
    @order = Order.new(order_params.merge(status: "pending", user_id: @current_user_id))
    @order.line_items.build(line_items_params)

    if @order.save
      render json: @order, status: :created
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # GET /orders/:id
  # View a specific order/cart
  def show
    render json: @order
  end

  # PATCH/PUT /orders/:id
  # Update order/cart (e.g., add items, update quantities)
  def update
    if @order.update(order_params)
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /orders/:id
  # Delete an order/cart
  def destroy
    @order.destroy
  end

  # POST /orders/:id/checkout
  # Transition an order from 'cart' status to 'completed' or other status
  def checkout
    if @order.checkout
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      # Assuming your order has a status and potentially other fields
      params.require(:order).permit(:status, :total_price, :user_id)
      # Include other parameters as needed, such as line item information
    end

    def line_items_params
      # Extract and return line item parameters
      params.require(:order).permit(line_items: [:product_id, :quantity, :price])[:line_items]
    end

end
