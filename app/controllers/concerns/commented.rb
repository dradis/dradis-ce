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
    @commentable ||= begin
      case params[:action]
      when 'index'
        Comment.new(
          commentable_type: params[:commentable_type],
          commentable_id: params[:commentable_id]
        ).commentable
      when 'create'
        Comment.new(
          commentable_type: params[:comment][:commentable_type],
          commentable_id: params[:comment][:commentable_id]
        ).commentable
      else
        # update, destroy
        Comment.find(params[:id]).commentable
      end
    end
  end

  def comments
    @comments ||= commentable&.comments&.includes(:user)
  end
end
