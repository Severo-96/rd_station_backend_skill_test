class RemoveAbandonedCartJob
  include Sidekiq::Job
  sidekiq_options queue: :default

  def perform
    Cart.where(abandoned: true)
        .where('last_interaction_at <= ?', 7.days.ago)
        .find_each(&:remove_abandoned_cart)
  end
end
