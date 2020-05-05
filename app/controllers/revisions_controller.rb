class RevisionsController < AuthenticatedController
  include ActivityTracking
  include NodesSidebar
  include ProjectScoped

  before_action :load_sidebar, except: [ :trash, :recover ]
  before_action :load_record, except: [ :trash, :recover ]

  def index
    redirect_to action: :show, id: @record.revisable_versions.last.try(:id) || 0
  end

  def show
    # Use `reorder`, not `order`, to override Paper Trail's default scope
    @revisions = @record.versions.includes(:item).reorder("created_at DESC")
    @revision  = @revisions.find(params[:id])

    @diffed_revision = DiffedRevision.new(@revision, @record)
  end

  def trash
    # Get all revisions whose event is destroy.
    @revisions = RecoverableRevision.all(project_id: current_project.id)
  end

  def recover
    revision = RecoverableRevision.find(id: params[:id], project_id: current_project.id)
    if revision.recover
      track_recovered(revision.object)
      flash[:info] = "#{revision.type} recovered"
    else
      flash[:error] = "Can't recover #{revision.type}: #{revision.errors.full_messages.join(',')}"
    end
    
    redirect_to project_trash_path(current_project)
  end

  def destroy
    RevisionCollapser.discard_and_revert(@record)

    # This is cheeky because either board and list won't be present or node
    # won't be present and removing nils makes valid paths.
    redirect_to polymorphic_path([current_project, @board, @list, @node, @record].concat)
  end

  private

  def load_list
    @board        = current_project.boards.includes(:lists).find(params[:board_id])
    @list         = @board.lists.includes(:cards).find(params[:list_id])
    @sorted_cards = @list.ordered_cards.select(&:persisted?)
  end

  def load_node
    @node = current_project.nodes.includes(
      :notes, :evidence, evidence: [:issue, { issue: :tags }]
    ).find_by_id(params[:node_id])

    # FIXME: from ProjectScoped
    initialize_nodes_sidebar
  end

  def load_record
    @record = if params[:card_id]
                @list.cards.find(params[:card_id])
              elsif params[:evidence_id]
                @node.evidence.find(params[:evidence_id])
              elsif params[:issue_id]
                Issue.find(params[:issue_id])
              elsif params[:note_id]
                @node.notes.find(params[:note_id])
              else
                raise 'Unable to identify record type'
              end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Record not found'
    redirect_to :back
  end

  def load_sidebar
    if params[:evidence_id] || params[:note_id]
      load_node
    elsif params[:card_id]
      load_list
    end
  end
end
