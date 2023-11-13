# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]
  before_action :authenticate_user, only: [:create, :destroy]

  # GET /products
  def index
    @products = Product.all

    render json: @products
  end

  def show
    render json: @product, status: :ok
  end

  # POST /products
  def create
    @product = Product.new(product_params.except(:images))
    attach_images if product_params[:images]

    if @product.save
      image_urls = @product.images.map { |image| rails_blob_url(image, only_path: true) }
      render json: @product.as_json.merge(images: image_urls), status: :created
    else
      render json: { errors: @product.errors}, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    head :no_content
  end

  private

  def set_product
    @product = Product.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Product not found' }, status: :not_found
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :inventory_count, images: [])
  end

  def attach_images
    product_params[:images].each do |image|
      @product.images.attach(image)
    end
  end
end
