module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :notifiable, dependent: :destroy
  end

  def create_notifications(action:, project:, recipients:)
    ActiveRecord::Base.transaction do
      recipients.each do |recipient|
        Notification.create(
          action: action,
          actor: user,
          notifiable: self,
          project: project,
          recipient: recipient
        )
      end
    end
  end
end
