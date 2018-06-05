class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true

  after_create :create_notifications

  def create_notifications
  end
end
