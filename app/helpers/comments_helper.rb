# frozen_string_literal: true

module CommentsHelper
  def comment_formatter(comment)
    @comment_pipeline ||= HTML::Pipeline.new [
      HTML::Pipeline::Dradis::TextileFilter,
      HTML::Pipeline::SanitizationFilter,
      HTML::Pipeline::AutolinkFilter,
      HTML::Pipeline::Dradis::MentionsFilter,
      HTML::Pipeline::Dradis::CodeHighlightFilter
    ], {
      no_inline_code: true,
      username_pattern: Comment::MENTION_PATTERN,
      view_context: self
    }

    result = @comment_pipeline.call(comment.content, mentionable_users: comment_mentionable_users(comment.commentable))
    result[:output].to_s.html_safe
  end

  def comment_mentionable_users(commentable)
    @comment_mentionable_users ||= {}
    @comment_mentionable_users[commentable] ||= Comment.mentionable_users(commentable).to_a
  end
end
