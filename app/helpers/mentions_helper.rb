# frozen_string_literal: true

module MentionsHelper
  def mention_matcher
    @mention_matcher ||= begin
      users = current_project.authors.all.select(:email, :name)

      matcher = /#{users.map { |user| '@' + user.email }.join('|')}/
      rules = users.each_with_object({}) do |user, hash|
        hash['@' + user.email] = avatar_image(user, size: 20, include_name: true, class: 'gravatar gravatar-inline')
      end

      [matcher, rules]
    end
  end

  def mentions_formatter(content)
    matcher, rules = mention_matcher
    content.gsub(matcher, rules)
  end
end
