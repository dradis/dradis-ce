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
end
