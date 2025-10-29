class MarkCartAsAbandonedJob
  include Sidekiq::Job
  sidekiq_options queue: :default

  def perform(*args)
    Cart.where('last_interaction_at <= ?', 3.hours.ago)
        .find_each do |cart|
      cart.mark_as_abandoned
      cart.remove_if_abandoned
    end
  end
end
