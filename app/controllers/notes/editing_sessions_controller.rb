class Notes::EditingSessionsController < AuthenticatedController
  include EditingSessionsActions
  include ProjectScoped

  before_action :set_note

  private

  def editing_session_record
    @note
  end

  def set_note
    @node = current_project.nodes.find(params[:node_id])
    @note = @node.notes.find(params[:note_id])
  end
end
