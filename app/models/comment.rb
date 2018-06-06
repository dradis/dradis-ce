class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  after_create :create_notifications
  after_create :create_subscription

  def create_notifications
    CreateNotificationsJob.perform_later(self)
  end

  def create_subscription
    Subscription.create(
      user: self.user,
      subscribable: self
    )
  end
end
