module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :notifiable, dependent: :destroy
  end

  def create_notifications(action:, recipients:)
    ActiveRecord::Base.transaction do
      recipients.each do |recipient|
        notification = Notification.create(
          action: action,
          actor: user,
          notifiable: self,
          recipient: recipient
        )
      end
    end
  end
end
