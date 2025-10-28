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
    let(:cart) { described_class.create!(total_price: 1, abandoned: true) }

    it 'marks the shopping cart as active' do
      expect { cart.mark_as_active }.to change { cart.abandoned }.from(true).to(false)
    end
  end

  describe 'mark_as_abandoned' do
    let(:cart) { described_class.create!(total_price: 1, last_interaction_at: 3.hours.ago) }

    it 'marks the shopping cart as abandoned if inactive for at least 3 hours' do
      expect { cart.mark_as_abandoned }.to change { cart.abandoned }.from(false).to(true)
    end

    context 'does not mark the shopping cart as abandoned if' do
      it 'it already is' do
        cart.update!(abandoned: true)
        cart.mark_as_abandoned
        expect { cart.mark_as_abandoned }.to_not change { cart.abandoned }
      end

      it 'it is not inactive for at least 3 hours' do
        cart.update!(last_interaction_at: 3.hours.ago + 1.minute)
        cart.mark_as_abandoned
        expect { cart.mark_as_abandoned }.to_not change { cart.abandoned }
      end
    end
  end

  describe 'remove_abandoned_cart' do
    let(:cart) { 
      described_class.create!(
        total_price: 1,
        abandoned: true,
        last_interaction_at: 7.days.ago - 1.hour
      )
    }

    it 'removes the shopping cart if abandoned for at least 7 days' do
      cart
      expect { cart.remove_abandoned_cart }.to change { Cart.count }.by(-1)
    end

    context 'does not remove the shopping cart if' do
      it 'it is not abandoned' do
        cart.update!(abandoned: false)
        expect { cart.remove_abandoned_cart }.to change { Cart.count }.by(0)
      end

      it 'it is not inactive for at least 7 days' do
        cart.update!(last_interaction_at: 7.days.ago + 1.minute)
        expect { cart.remove_abandoned_cart }.to change { Cart.count }.by(0)
      end
    end
  end
end
