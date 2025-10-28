class Cart < ApplicationRecord
  enum status: { open: 0, abandoned: 1 }

  has_many :cart_items, dependent: :destroy

  validates_numericality_of :total_price, greater_than_or_equal_to: 0


  def create_cart_item(item_params)
    self.class.transaction do
      cart_items.create!(item_params)
      self.total_price += added_product_total_price(item_params)
      save!
    end
    
    self
  end

  private

  def added_product_total_price(item_params)
    product = Product.find(item_params[:product_id])

    product.price * item_params[:quantity].to_d
  end

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
