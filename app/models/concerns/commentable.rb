module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :destroy
  end

  def commentable_activities
    Activity.where(trackable_type: self.class.to_s, trackable_id: self.id).or(
      Activity.where(trackable_type: 'Comment', trackable_id: [self.comments.map(&:id)])
    )
  end
end
