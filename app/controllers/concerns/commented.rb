# This module can be included anywhere comments are rendered. Any item that is
# commentable can use this module to help render comment collections in views.
# It will load comments and authors without n+1 as well as build avatars for all
# mentions within the collection of comments. Additionally it can be used where
# a single comment is rendered such as activity polling, or comment creation via
# ajax.
module Commented
  extend ActiveSupport::Concern

  included do
    helper_method :commentable, :comments
  end

  def commentable
    instance_variable_get("@#{controller_name.singularize}")
  end

  def comments
    @comments ||= commentable&.comments&.includes(:user)
  end
end
