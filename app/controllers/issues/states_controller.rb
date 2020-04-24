class Issues::StatesController < AuthenticatedController

  def update_states
    @issues = Issue.where(id: params[:ids])
    @issues.update_all(state: params[:state])

    head :ok
  end

end
