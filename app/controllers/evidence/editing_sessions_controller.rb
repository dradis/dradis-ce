class Evidence::EditingSessionsController < AuthenticatedController
  include EditingSessionsActions
  include ProjectScoped

  private

  def lockable_resource
    node = current_project.nodes.find(params[:node_id])
    node.evidence.find(params[:evidence_id])
  end
end
