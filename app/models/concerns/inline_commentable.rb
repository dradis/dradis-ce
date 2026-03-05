module InlineCommentable
  extend ActiveSupport::Concern

  mattr_accessor :allowed_types, default: []

  included do |base|
    InlineCommentable.allowed_types << base.name

    has_many :inline_comment_threads, as: :commentable, dependent: :destroy
  end
end
