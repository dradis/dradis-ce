# frozen_string_literal: true

module CommentsHelper
  def comment_formatter(comment)
    @comment_pipeline ||= HTML::Pipeline.new [
      HTML::Pipeline::DradisFieldableFilter,
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
