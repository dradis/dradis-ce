class RevisionsController < ProjectScopedController
  before_filter :load_node, except: [ :trash, :recover ]
  before_filter :load_record, except: [ :trash, :recover ]

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

    time_format = "%b %e %Y, %-l:%M%P"

    @updated_at      = after["updated_at"].strftime(time_format)
    @last_updated_at = before["updated_at"].strftime(time_format)

    content_attribute = case @record
                        when Issue, Note; 'text'
                        when Evidence; 'content'
                        end

    @diff = Differ.diff_by_line(
              after[content_attribute],
              before[content_attribute]
            )
  end

  def trash
    # Get all versions whose event is destroy.
    @revisions = PaperTrail::Version.where(event: 'destroy').order(created_at: :desc)
  end

  def recover
    revision = PaperTrail::Version.find params[:id]
    object = revision.reify
    # If object's node was destroyed, assign it no a new node.
    if !Node.exists?(object.node_id)
      recovered_node = Node.create(label: 'Recovered', type_id: Node::Types::DEFAULT)
      object.node_id = recovered_node.id
    end

    # If object is evidence and its issue doesn't exist any more, recover it.
    if revision.item_type == 'Evidence' and !Note.exists?(object.issue_id)
      issue_revision = PaperTrail::Version.where(event: 'destroy', item_type: 'Note', item_id: object.issue_id).limit(1).first
      # A destroy revision should always be present, but just in case.
      if issue_revision
        issue_object = issue_revision.reify
        issue_object.node_id = Node.issue_library.id
        issue_object.save
        object.issue_id = issue_object.id
        issue_revision.destroy
      end
    end

    if object.save
      # Destroy revision so item is not listed in trash any more.
      revision.destroy
      flash[:info] = 'Item recovered'
    else
      flash[:error] = "Can't recover item."
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
