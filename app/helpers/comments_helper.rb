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
      mentionable_users: @mentionable_users,
      no_inline_code: true,
      username_pattern: Comment::MENTION_PATTERN,
      view_context: self
    }

    result = @comment_pipeline.call(comment)
    result[:output].to_s.html_safe
  end
end
