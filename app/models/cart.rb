class Cart < ApplicationRecord
  enum status: { open: 0, abandoned: 1 }

  has_many :cart_items, dependent: :destroy

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
