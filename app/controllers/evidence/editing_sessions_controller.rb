class Evidence::EditingSessionsController < AuthenticatedController
  include ProjectScoped

  before_action :set_evidence

  def destroy
    @evidence.release_edit_session(current_user)
    head :no_content
  end

  private

  def set_evidence
    @node = current_project.nodes.find(params[:node_id])
    @evidence = @node.evidence.find(params[:evidence_id])
  end
end
