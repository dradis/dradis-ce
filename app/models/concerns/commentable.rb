module Commentable
  extend ActiveSupport::Concern

  mattr_accessor :allowed_types, default: []

  included do |base|
    Commentable.allowed_types << base.name

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
