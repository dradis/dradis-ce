module QAStates
  extend ActiveSupport::Concern

  included do
    before_action :set_states, only: [:new, :create, :edit, :update]

    before_action :ensure_reviewer, only: [:create, :update, :multiple_update]
  end

  private

  def ensure_reviewer
    params_method = "#{controller_name.singularize}_params"
    return unless self.respond_to?(params_method)

    record_params = self.send(params_method)

    if (record_params[:state] == 'published' || params[:state] == 'published') &&
        !can?(:publish, @issue)

      redirect_to project_issues_path(current_project), alert: 'Unable to publish record!'
    end
  end

  def set_states
    @states = Issue.states.dup
  end
end
