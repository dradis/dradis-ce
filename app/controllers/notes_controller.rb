# This controller exposes the REST operations required to manage the Note
# resource.
class NotesController < NestedNodeResourceController

  before_action :find_or_initialize_note, except: [:index, :new, :multi_destroy]
  before_action :initialize_nodes_sidebar, only: [:edit, :new, :show]

  def new
    @note      = @node.notes.new

    # See ContentFromTemplate concern
    @note.text = template_content if params[:template]
  end

  # Create a new Note for the associated Node.
  def create
    @note.author = current_user.email
    @note.category ||= Category.default

    if @note.save
      track_created(@note)
      redirect_to node_note_path(@node, @note), notice: 'Note created'
    else
      initialize_nodes_sidebar
      render "new"
    end
  end

  # Retrieve a Note given its :id
  def show
    @activities = @note.activities.latest
    load_conflicting_revisions(@note)
  end

  def edit
    @versions_count = @note.versions.count
  end

  # Update the attributes of a Note
  def update
    updated_at_before_save = @note.updated_at.to_i
    if @note.update_attributes(note_params)
      track_updated(@note)
      check_for_edit_conflicts(@note, updated_at_before_save)
      redirect_to node_note_path(@note.node, @note), notice: 'Note updated.'
    else
      initialize_nodes_sidebar
      render 'edit'
    end
  end

  # Remove a Note from the back-end database.
  def destroy
    if @note.destroy
      track_destroyed(@note)
      redirect_to node_path(@node), notice: 'Note deleted'
    else
      redirect_to node_note_path(@node, @note), alert: 'Could not delete note'
    end
  end

  def multi_destroy
    notes = Note.where(
      'node_id = :node AND id in (:ids)',
      node: @node,
      ids: params[:ids]
    )

    deleted = 0
    notes.each do |note|
      if note.destroy
        track_destroyed(note)
        deleted += 1
      end
    end

    if deleted = notes.size
      redirect_to node_path(@node, tab: 'notes-tab'), notice: 'Notes deleted'
    else
      redirect_to @node, tab: 'notes-tab', alert: 'Could not delete notes'
    end
  end

  private

  # Once a valid @node is set by the previous filter we look for the Note we
  # are going to be working with based on the :id passed by the user.
  def find_or_initialize_note
    if params[:id]
      @note = Note.find(params[:id])
    elsif params[:note]
      @note = @node.notes.new(note_params)
    else
      @note = @node.notes.new
    end
  end

  def note_params
    params.require(:note).permit(:category_id, :text, :node_id)
  end
end
