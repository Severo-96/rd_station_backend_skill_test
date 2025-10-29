require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'mark_as_active' do
    let(:shopping_cart) { create(:cart, :abandoned) }

    it 'marks the shopping cart as active' do
      expect { shopping_cart.mark_as_active }.to change { shopping_cart.abandoned }.from(true).to(false)
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned }.from(false).to(true)
    end

    context 'does not mark the shopping cart as abandoned if' do
      it 'it already is' do
        shopping_cart.update!(abandoned: true)
        shopping_cart.mark_as_abandoned
        expect { shopping_cart.mark_as_abandoned }.to_not change { shopping_cart.abandoned }
      end

      it 'it is not inactive for at least 3 hours' do
        shopping_cart.update!(last_interaction_at: 3.hours.ago + 1.minute)
        shopping_cart.mark_as_abandoned
        expect { shopping_cart.mark_as_abandoned }.to_not change { shopping_cart.abandoned }
      end
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end

    context 'does not remove the shopping cart if' do
      it 'it is not abandoned' do
        shopping_cart.update!(abandoned: false)
        expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(0)
      end

      it 'it is not inactive for at least 7 days' do
        shopping_cart.mark_as_abandoned
        shopping_cart.update!(last_interaction_at: 7.days.ago + 1.minute)
        expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(0)
      end
    end
  end
end
