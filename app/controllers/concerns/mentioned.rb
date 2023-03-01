module Mentioned
  extend ActiveSupport::Concern

  included do
    # If this needs to be any more complicated put the before actions
    # in each individual controller.
    actions = controller_path == 'comments' ? [:index, :create, :show, :update] : [:show]
    before_action :find_mentionable_users, only: actions
  end

  protected

  def find_mentionable_users
    @mentionable_users ||= begin
      resource = (project || instance_variable_get("@#{controller_name.singularize}") || commentable)
      Comment.mentionable_users(resource)
    end
  end

  def project
    @project ||= begin
      if defined?(current_project)
        current_project
      else
        nil
      end
    end
  end
end
