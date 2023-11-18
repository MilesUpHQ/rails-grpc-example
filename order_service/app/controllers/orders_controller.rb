class OrdersController < ApplicationController
  before_action :authenticate_user, only: [:create, :update, :cart, :remove_item]
  before_action :set_order, only: [:show, :update, :destroy, :checkout]

  # POST /orders
  # This will create a new order, acting as a cart initially
  def create
    @order = find_or_create_cart
    update_or_add_line_items

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
      render json: cart.as_json.merge(line_items: cart.line_items_with_product_details), status: :ok
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

  def remove_item
    line_item = LineItem.find_by(id: params[:line_item_id], order_id: params[:order_id])

    if line_item
      line_item.destroy
      render json: line_item, status: :ok
    else
      render json: { error: 'Item not found in cart' }, status: :not_found
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

    def update_or_add_line_items
      line_items_params&.each do |line_item_params|
        existing_item = @order.line_items.find_by(product_id: line_item_params[:product_id])
        if existing_item
          # Update quantity of the existing item
          existing_item.quantity = line_item_params[:quantity].to_i
          existing_item.save
        else
          # Add as a new line item
          @order.line_items.build(line_item_params)
        end
      end
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


    def order_params
      params.require(:order).permit(:status, :total_price, :user_id, :guest_id, line_items_attributes: [:id, :product_id, :quantity, :price])
    end

    def line_items_params
      # Extract and return line item parameters
      params.require(:order).permit(line_items: [:id, :product_id, :quantity, :price])[:line_items]
    end

end
