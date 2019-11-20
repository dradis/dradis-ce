# frozen_string_literal: true

module CommentsHelper
  def mention_matcher
    @mention_matcher ||= begin
      users = @mentionable_users || current_project.authors

      matcher = /#{users.map { |user| '@' + user.email }.join('|')}/
      rules = users.each_with_object({}) do |user, hash|
        hash['@' + user.email] = avatar_image(user, size: 20, include_name: true, class: 'gravatar gravatar-inline')
      end

      [matcher, rules]
    end
  end

  def comment_formatter(comment)
    comment_pipeline = HTML::Pipeline.new [
      HTML::Pipeline::DradisCommentFilter,
      HTML::Pipeline::DradisMentionsFilter,
    ], { mention_matcher: mention_matcher }

    result = comment_pipeline.call(comment)
    result[:output].to_s.html_safe
  end
end
