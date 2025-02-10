module Publishable
  extend ActiveSupport::Concern

  included do
    before_action :ensure_reviewer, only: [:create, :update, :multiple_update]
  end

  private

  def ensure_reviewer
    return if can?(:publish, current_project)

    record_params = self.send("#{controller_name.singularize}_params")
    current_state = record&.state

    if (current_state != 'published' && record_params[:state] == 'published') ||
        params[:state] == 'published'

      redirect_to project_issues_path(current_project), alert: 'Unable to publish record!'
    elsif current_state == 'published' && record_params[:state] == ''
      # If the user is not a reviewer, and the record is currently set as
      # 'Published', the radio button will be disabled and record_params[:state]
      # will be '' (empty string). Since an empty state is invalid, we delete
      # the param here instead.
      params[controller_name.singularize].delete(:state)
    end
  end

  def record
    return unless params[:id]

    klass = controller_name.classify.constantize
    klass.find(params[:id])
  end
end
