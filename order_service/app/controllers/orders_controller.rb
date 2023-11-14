class OrdersController < ApplicationController
  before_action :authenticate_user, only: [:create, :update, :cart]
  before_action :set_order, only: [:show, :update, :destroy, :checkout]

  # POST /orders
  # This will create a new order, acting as a cart initially
  def create
    @order = find_or_create_cart
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

  def cart
    cart = find_current_user_cart
    if cart
      render json: cart, status: :ok
    else
      render json: { message: 'No active cart found' }, status: :not_found
    end
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

    def find_or_create_cart
      user_or_guest_id = @current_user_id ? { user_id: @current_user_id } : { guest_id: @current_guest_id }

      old_cart = Order.where(status: "cart").where(user_or_guest_id)
                      .order(created_at: :desc)
                      .first
      old_cart || Order.new(order_params.merge(status: "cart").merge(user_or_guest_id))
    end

    def find_current_user_cart
      if @current_user_id
        # Find cart for authenticated user
        Order.where(status: "cart", user_id: @current_user_id).order(created_at: :desc).first
      elsif @current_guest_id
        # Find cart for guest user
        Order.where(status: "cart", guest_id: @current_guest_id).order(created_at: :desc).first
      end
    end

    # def current_user_or_guest_id
    #   # Assumes @current_user_id and @current_guest_id are set in authenticate_user
    #   @current_user_id || @current_guest_id
    # end


    def order_params
      params.require(:order).permit(:status, :total_price, :user_id, :guest_id)
    end

    def line_items_params
      # Extract and return line item parameters
      params.require(:order).permit(line_items: [:product_id, :quantity, :price])[:line_items]
    end

end
