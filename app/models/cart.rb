class Cart < ApplicationRecord
  enum status: { open: 0, abandoned: 1 }

  has_many :cart_items, dependent: :destroy

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def create_cart_item(item_params)
    self.class.transaction do
      cart_items.create!(item_params)
      self.total_price = products_total_price
      save!
    end
    
    self
  end

  def update_cart_item(item_params)
    self.class.transaction do
      cart_item = cart_items.find_by!(product_id: item_params[:product_id])
      cart_item.quantity += item_params[:quantity]
      cart_item.save!

      self.total_price = products_total_price
      save!
    end

    self
  end

  def remove_cart_item(product_id)
    self.class.transaction do
      cart_item = cart_items.find_by!(product_id:)
      cart_item.destroy!

      self.total_price = products_total_price
      save!
    end

    self
  end

  private

  def products_total_price
    cart_items.includes(:product).sum do |item|
      item.product.price * item.quantity
    end
  end

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
