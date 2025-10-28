class CartsController < ApplicationController
  before_action :set_cart

  # POST /cart
  def create
    ActiveRecord::Base.transaction do
      if @cart.nil?
        @cart = Cart.create!(total_price: 0)
        session[:cart_id] = @cart.id
      end

      @cart.create_cart_item(item_params)
    end

    render_cart
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotUnique => e
    render json: { error: "Product already on cart" }, status: :unprocessable_entity
  end

  # GET /cart
  def show
    return render_cart if @cart.present?

    render json: { error: "Cart not found" }, status: :not_found
  end

  private

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id])
  end

  def item_params
    params.permit(:product_id, :quantity)
  end

  def render_cart
    cart_items = @cart.cart_items.includes(:product)

    render json: {
      id: @cart.id,
      total_price: @cart.total_price,
      products: cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price,
          total_price: item.quantity * item.product.price
        }
      end
    }, status: :ok
  end
end
