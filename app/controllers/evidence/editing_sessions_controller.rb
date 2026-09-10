class Evidence::EditingSessionsController < AuthenticatedController
  include EditingSessionsActions
  include ProjectScoped

  before_action :set_evidence

  private

  def editing_session_record
    @evidence
  end

  def set_evidence
    @node = current_project.nodes.find(params[:node_id])
    @evidence = @node.evidence.find(params[:evidence_id])
  end
end
