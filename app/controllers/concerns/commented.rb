module Commented
  extend ActiveSupport::Concern

  included do
    helper_method :commentable, :comments, :mentions_builder
  end

  def commentable
    instance_variable_get("@#{controller_name.singularize}")
  end

  def comments
    @comments ||= commentable&.comments&.includes(:user)
  end

  def mentioned_users(comments)
    # Match any non whitespace that starts with an @ has another @
    emails = comments.inject([]) do |collection, comment|
      (collection + comment.scan(/@(\S*@\S*)/)).flatten.uniq
    end

    current_project.authors.where(email: emails)
  end

  def mentions_builder(comments)
    @mentions_builder ||= begin
      users = mentioned_users(Array(comments))

      matcher = /#{users.map { |user| '@' + user.email }.join('|')}/
      rules = users.each_with_object({}) do |user, hash|
        hash['@' + user.email] = view_context.avatar_image(user, size: 20, include_name: true, class: 'gravatar gravatar-inline')
      end

      [matcher, rules]
    end
  end
end
