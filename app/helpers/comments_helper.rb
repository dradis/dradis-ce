# frozen_string_literal: true

module CommentsHelper
  def comment_formatter(comment)
    # We don't use Dradis Style headers in comments as the comment doesn't use
    # the fieldable module or have the concept of fields.
    @comment_pipeline ||= HTML::Pipeline.new [
      HTML::Pipeline::DradisTextileFilter,
      HTML::Pipeline::SanitizationFilter,
      HTML::Pipeline::AutolinkFilter,
      HTML::Pipeline::DradisMentionsFilter,
      HTML::Pipeline::DradisCodeHighlightFilter
    ], {
      mentionable_users: @mentionable_users || current_project.testers_for_mentions,
      username_pattern: Comment::MENTION_PATTERN,
      view_context: self
    }

    result = @comment_pipeline.call(comment)
    result[:output].to_s.html_safe
  end
end
