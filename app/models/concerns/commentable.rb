module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :destroy
  end

  def commentable_activities
    self.activities.or(
      Activity.where(
        trackable_type: 'Comment',
        trackable_id: self.comments.pluck(:id)
      )
    )
  end
end
