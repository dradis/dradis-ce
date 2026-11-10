module Mentioned
  extend ActiveSupport::Concern

  included do
    # Resource #show pages render the meta tag Tribute uses for @mention
    # autocomplete (see the layout). Views that format comments load the users
    # on demand through the mentionable_users helper.
    before_action :enable_mention_autocomplete, only: [:show]
    helper_method :mentionable_users
  end

  protected

  def enable_mention_autocomplete
    @mention_autocomplete = true
  end

  def mentionable_users
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
