class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def create_cart_item(item_params)
    self.class.transaction do
      cart_items.create!(item_params)
      update_cart_total_price
    end
    
    self
  end

  def update_cart_item(item_params)
    self.class.transaction do
      cart_item = cart_items.find_by!(product_id: item_params[:product_id])
      cart_item.quantity += item_params[:quantity]
      cart_item.save!
      update_cart_total_price
    end

    self
  end

  def remove_cart_item(product_id)
    self.class.transaction do
      cart_item = cart_items.find_by!(product_id:)
      cart_item.destroy!
      update_cart_total_price
    end

    self
  end

  def mark_as_active
    touch(:last_interaction_at)
    update!(abandoned: false) if abandoned?
  end

  def mark_as_abandoned
    return unless last_interaction_at <= 3.hours.ago && !abandoned?

    update!(abandoned: true) 
  end

  def remove_if_abandoned
    return unless abandoned? && last_interaction_at <= 7.days.ago

    destroy!
  end

  private

  def update_cart_total_price
    products_total_price = cart_items.includes(:product).sum do |item|
      item.product.price * item.quantity
    end
    self.update!(total_price: products_total_price)
  end
end
