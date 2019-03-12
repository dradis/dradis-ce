module Commented
  extend ActiveSupport::Concern

  included do
    helper_method :commentable, :comments
  end

  def commentable
    instance_variable_get("@#{controller_name.singularize}")
  end

  def comments
    @comments ||= commentable.comments.includes(:user)
  end
end
