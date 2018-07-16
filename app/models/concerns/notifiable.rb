module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :notifiable, dependent: :destroy
  end

  def create_notifications(action:, recipients:)
    ActiveRecord::Base.transaction do
      recipients.each do |recipient|
        Notification.create(
          action: action,
          actor: user,
          notifiable: self,
          recipient: recipient
        )
      end
    end
  end

  def broadcast_notifications(recipients:)
    recipients.each do |user|
      NotificationsChannel.broadcast_to(user, item: self)
    end
  end
end
