class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  after_create :create_notifications

  def create_notifications
  end
end
