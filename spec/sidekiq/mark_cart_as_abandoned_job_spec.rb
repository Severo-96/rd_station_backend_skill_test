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
end

