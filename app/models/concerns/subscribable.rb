module Subscribable
  extend ActiveSupport::Concern

  included do
    has_many :subscriptions, as: :subscribable, dependent: :destroy

    after_create :create_subscription
  end

  def create_subscription
    if respond_to?(:author) && user = User.find_by_email(author)
      Subscription.subscribe(user: user, to: self)
    end
  end

  def subscription_for(user: user)
    self.subscriptions.find_by(
      user: user,
      subscribable_type: self.class.to_s,
      subscribable_id: self.id
    )
  end
end
