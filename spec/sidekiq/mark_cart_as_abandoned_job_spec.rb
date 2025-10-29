require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  it 'queues job on default' do
    expect { described_class.perform_async }.to change(described_class.jobs, :size).by(1)
    expect(described_class.jobs.last['queue']).to eq('default')
  end

  it 'executes and mark as abandoned only the eligible carts' do
    Sidekiq::Testing.inline! do
      #cart without interaction for at least 3 hours
      cart_one = create(:cart, :abandoned, last_interaction_at: 3.hours.ago)

      #cart without interaction for less than 3 hours
      cart_two = create(:cart, last_interaction_at: 3.hours.ago + 1.minute)

      #cart already abandoned
      cart_three = create(:cart, :abandoned, last_interaction_at: 1.day.ago)

      expect { described_class.perform_async }.to change(Cart, :count).by(0)

      expect(cart_one.reload.abandoned).to be_truthy
      expect(cart_two.reload.abandoned).to be_falsey
      expect(cart_three.reload.abandoned).to be_truthy
    end
  end

  it 'executes and removes only the eligible carts' do
    Sidekiq::Testing.inline! do
      #cart abandoned and without interaction for at least 7 days
      cart_one = create(:cart, :abandoned, last_interaction_at: 7.days.ago)

      #cart abandoned and without interaction for less than 7 days
      cart_two = create(:cart, :abandoned, last_interaction_at: 7.days.ago + 1.hour)

      #cart not abandoned
      cart_three = create(:cart, last_interaction_at: 10.days.ago)

      expect { described_class.perform_async }.to change(Cart, :count).by(-2)

      expect(Cart.exists?(cart_one.id)).to be_falsey
      expect(Cart.exists?(cart_two.id)).to be_truthy
      expect(Cart.exists?(cart_three.id)).to be_falsey
    end
  end
end

