module Commented
  extend ActiveSupport::Concern

  included do
    helper_method :commentable, :comments,
                  :mentioned_users_replacement_rules, :mentioned_users_matcher
  end

  def commentable
    instance_variable_get("@#{controller_name.singularize}")
  end

  def comments
    @comments ||= commentable.comments.includes(:user)
  end

  def mentioned_users
    @mentioned_users ||= begin
      # Match any non whitespace that starts with an @ has another @
      emails = comments.inject([]) do |collection, comment|
        (collection + comment.content.scan(/@(\S*@\S*)/)).flatten.uniq
      end

      current_project.authors.where(email: emails)
    end
  end

  def mentioned_users_matcher
    @mentioned_users_matcher ||= /#{mentioned_users.map { |user| '@' + user.email }.join('|')}/
  end

  def mentioned_users_replacement_rules
    @mentioned_users_replacement_rules ||= mentioned_users.each_with_object({}) do |user, hash|
      hash['@' + user.email] = view_context.avatar_image(user, size: 20, include_name: true, class: 'gravatar gravatar-inline')
    end
  end
end
