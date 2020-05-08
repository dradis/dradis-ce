class Issues::StatesController < AuthenticatedController
  include ProjectScoped

  def update_states
    issues = current_project.issues.where(id: params[:ids])

    if issues.update_all(state: state_params, updated_at: Time.now)
      render json: { state: Issue.state_names[state_params] }
    else
      render json: { message: 'Something went wrong.' }
    end
  end

  private

  def state_params
    @state_params ||=
      if Issue.states.keys.include?(params[:state])
        params[:state]
      else
        :published
      end
  end
end
