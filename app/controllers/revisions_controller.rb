class RevisionsController < ProjectScopedController
  before_filter :load_node
  before_filter :load_record

  def index
    redirect_to action: :show, id: @record.versions.last.try(:id) || 0
  end

  def show
    # Use `reorder`, not `order`, to override Paper Trail's default scope
    @revisions = @record.versions.includes(:item).reorder("created_at DESC")
    @revision  = @revisions.find(params[:id])

    # If this is the 1st revision, there's nothing to compare. There shouldn't
    # be any links to this page, so if you get here it's a programmer error.
    raise "can't show diff first revision" unless @revision.previous.present?

    @this_author     = @revision.whodunnit
    @previous_author = @revision.previous.whodunnit

    # Version#object is the state of the object *before* the change was made.
    before = YAML.load(@revision.object)
    after  = if next_revision = @revision.next
               YAML.load(next_revision.object)
             else
               @record.attributes
             end

    @updated_at      = after["updated_at"].strftime(RevisionsHelper::DATE_FORMAT)
    @last_updated_at = before["updated_at"].strftime(RevisionsHelper::DATE_FORMAT)

    content_attribute = case @record
                        when Issue, Note; 'text'
                        when Evidence; 'content'
                        end

    @diff = Differ.diff_by_line(
              after[content_attribute],
              before[content_attribute]
            )
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
