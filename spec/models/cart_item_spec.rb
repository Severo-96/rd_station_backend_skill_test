require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'when validating' do
    it 'validates numericality of quantity' do
      cart_item = described_class.new(quantity: -1)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("must be greater than or equal to 0")
    end
  end
end
