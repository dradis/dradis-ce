# This module can be included anywhere comments are rendered. Any item that is
# commentable can use this module to help render comment collections in views.
# It will load comments and authors without n+1 as well as build avatars for all
# mentions within the collection of comments. Additionally it can be used where
# a single comment is rendered such as activity polling, or comment creation via
# ajax.
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

  # When called this will scan the provided comments for email addresses and
  # search for users of the current project with that address. It then builds
  # out a hash of avatars as a lookup and replacement for all comments in the
  # thread.
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
