class RevisionsController < ProjectScopedController
  before_filter :load_node, except: [ :trash, :recover ]
  before_filter :load_record, except: [ :trash, :recover ]

  def index
    redirect_to action: :show, id: @record.versions.where(event: 'update').last.try(:id) || 0
  end

  def show
    # Use `reorder`, not `order`, to override Paper Trail's default scope
    @revisions = @record.versions.includes(:item).reorder("created_at DESC")
    @revision  = @revisions.find(params[:id])

    @diffed_revision = DiffedRevision.new(@revision, @record)
  end

  def trash
    # Get all revisions whose event is destroy.
    @revisions = RecoverableRevision.all
  end

  def recover
    revision = RecoverableRevision.find(params[:id])
    if revision.recover
      track_recovered(revision.object)
      flash[:info] = "#{revision.type} recovered"
    else
      flash[:error] = "Can't recover #{revision.type}: #{revision.errors.full_messages.join(',')}"
    end
    
    redirect_to trash_path
  end

  private
  def load_node
    if params[:evidence_id] || params[:note_id]
      @node = Node.includes(
        :notes, :evidence, evidence: [:issue, { issue: :tags }]
      ).find_by_id(params[:node_id])

      # FIXME: from ProjectScopedController
      initialize_nodes_sidebar
    end
  end

  def load_record
    @record = if params[:evidence_id]
                @node.evidence.find(params[:evidence_id])
              elsif params[:note_id]
                @node.notes.find(params[:note_id])
              elsif params[:issue_id]
                Issue.find(params[:issue_id])
              else
                raise 'Unable to identify record type'
              end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Record not found'
    redirect_to :back
  end
end
