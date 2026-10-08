class Notes::EditingSessionsController < AuthenticatedController
  include EditingSessionsActions
  include ProjectScoped

  private

  def lockable_resource
    node = current_project.nodes.find(params[:node_id])
    node.notes.find(params[:note_id])
  end
end
