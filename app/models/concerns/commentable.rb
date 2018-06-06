module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :destroy
    has_many :notifications, as: :notifiable
    has_many :subscriptions, as: :subscribable, dependent: :destroy
  end
end
