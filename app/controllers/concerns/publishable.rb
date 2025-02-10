module Publishable
  extend ActiveSupport::Concern

  included do
    before_action :ensure_reviewer, only: [:create, :update, :multiple_update]
  end

  private

  def ensure_reviewer
    params_method = "#{controller_name.singularize}_params"
    return if can?(:publish, current_project) || !self.respond_to?(params_method)

    record_params = self.send(params_method)
    current_state =
      self.get_instance_variable("@#{controller_name.singularize}")&.state

    if (record_params[:state] == 'published' && current_state != 'published') ||
        params[:state] == 'published'

      redirect_to project_issues_path(current_project), alert: 'Unable to publish record!'
    end
  end
end
