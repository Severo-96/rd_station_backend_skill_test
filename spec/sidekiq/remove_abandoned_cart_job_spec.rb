require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe RemoveAbandonedCartJob, type: :job do
  it 'queues job on default' do
    expect { described_class.perform_async }.to change(described_class.jobs, :size).by(1)
    expect(described_class.jobs.last['queue']).to eq('default')
  end

  it 'executes and removes only the eligible carts' do
    Sidekiq::Testing.inline! do
      #cart abandonado a 7 dias
      cart_one = Cart.create!(total_price: 1, abandoned: true, last_interaction_at: 7.days.ago)

      #cart abandonado a menos de 7 dias
      cart_two = Cart.create!(total_price: 1, abandoned: true, last_interaction_at: 7.days.ago + 1.hour)

      #cart nao abandonado
      cart_three  = Cart.create!(total_price: 1, abandoned: false, last_interaction_at: 10.days.ago)

      expect { described_class.perform_async }.to change(Cart, :count).by(-1)

      expect(Cart.exists?(cart_one.id)).to be_falsey
      expect(Cart.exists?(cart_two.id)).to be_truthy
      expect(Cart.exists?(cart_three.id)).to be_truthy
    end
  end
end

