module CommentMacros
  extend ActiveSupport::Concern

  include ActionView::RecordIdentifier

  def comment_feed
    '.comment-feed'
  end

  def have_comment(comment)
    have_selector "##{dom_id(comment)}"
  end
end
