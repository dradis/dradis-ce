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

  def commentable_display_name
    if defined?(self.class::COMMENTABLE_DISPLAY_NAME)
      self.class::COMMENTABLE_DISPLAY_NAME
    else
      self.class.name.demodulize
    end
  end
end
