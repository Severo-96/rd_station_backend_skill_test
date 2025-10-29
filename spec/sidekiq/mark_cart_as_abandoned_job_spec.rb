require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  it 'queues job on default' do
    expect { described_class.perform_async }.to change(described_class.jobs, :size).by(1)
    expect(described_class.jobs.last['queue']).to eq('default')
  end

  it 'executes and mark as abandoned only the eligible carts' do
    Sidekiq::Testing.inline! do
      #cart sem interação a 3 horas
      cart_one = Cart.create!(total_price: 1, abandoned: false, last_interaction_at: 3.hours.ago - 1.minute)

      #cart sem interação a menos de 3 horas
      cart_two = Cart.create!(total_price: 1, abandoned: false, last_interaction_at: 3.hours.ago + 1.minute)

      #cart já abandonado
      cart_three  = Cart.create!(total_price: 1, abandoned: true, last_interaction_at: 1.day.ago)

      expect { described_class.perform_async }.to change(Cart, :count).by(0)

      expect(cart_one.reload.abandoned).to be_truthy
      expect(cart_two.reload.abandoned).to be_falsey
      expect(cart_three.reload.abandoned).to be_truthy
    end
  end

  it 'executes and removes only the eligible carts' do
    Sidekiq::Testing.inline! do
      #cart abandonado a 7 dias
      cart_one = Cart.create!(total_price: 1, abandoned: true, last_interaction_at: 7.days.ago)

      #cart abandonado a menos de 7 dias
      cart_two = Cart.create!(total_price: 2, abandoned: true, last_interaction_at: 7.days.ago + 1.hour)

      #cart nao abandonado
      cart_three = Cart.create!(total_price: 3, abandoned: false, last_interaction_at: 10.days.ago)

      expect { described_class.perform_async }.to change(Cart, :count).by(-2)

      expect(Cart.exists?(cart_one.id)).to be_falsey
      expect(Cart.exists?(cart_two.id)).to be_truthy
      expect(Cart.exists?(cart_three.id)).to be_falsey
    end
  end
end

