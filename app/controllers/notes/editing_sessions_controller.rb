class Notes::EditingSessionsController < AuthenticatedController
  include ProjectScoped

  before_action :set_note

  def destroy
    @note.release_edit_session(current_user)
    head :no_content
  end

  private

  def set_note
    node = current_project.nodes.find(params[:node_id])
    @note = node.notes.find(params[:note_id])
  end
end
