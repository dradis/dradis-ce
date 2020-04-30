class Issues::StatesController < AuthenticatedController
  include ProjectScoped

  def update_states
    issues = current_project.issues.where(id: params[:ids])
    issues.update_all(state: params[:state])

    head :ok
  end

end
