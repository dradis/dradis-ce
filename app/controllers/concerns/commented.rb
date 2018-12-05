module Commented
  extend ActiveSupport::Concern

  included do
    before_action :set_comments, only: :show
  end

  protected

  def set_comments
    resource = controller_name.singularize
    send("find_or_initialize_#{resource}".to_sym)
    @commentable = instance_variable_get("@#{resource}")
    @comments = @commentable.comments.includes(:user)

  end
end
