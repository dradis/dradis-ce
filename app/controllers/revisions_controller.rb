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

  def trash
    # Get all versions whose event is destroy.
    @revisions = PaperTrail::Version.where(event: 'destroy').order(created_at: :desc)
  end

  def recover
    revision = PaperTrail::Version.find params[:id]
    object   = revision.reify

    # If we're recovering an issue, revision.reify will return an instance
    # of `Note`, because `revision.reify.item_type == "Note"`. This won't prevent
    # the issue from being recovered correctly (because `revision.reify.node_id
    # == Node.issue_library.id`), it will break the activity feed, because
    # track_activity will create an Activity with `trackable_type == "Note"`,
    # not `trackable_type == "Issue"`.  So if revision.reify returns a Note
    # which should be an issue, convert it to an instance of Issue:
    if object.instance_of?(Note) && object.node_id == Node.issue_library.id
      object = Issue.new(object.attributes)
    end

    # If object's node was destroyed, assign it to a new node.
    object.node = Node.recovered if !Node.exists?(object.node_id)

    # If object is evidence and its issue doesn't exist any more, recover the issue.
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

    class_name = object.class.name.humanize
    if object.save
      # Destroy revision so item is not listed in trash any more.
      revision.destroy
      track_recovered(object)
      flash[:info] = "#{class_name} recovered"
    else
      flash[:error] = "Can't recover #{class_name}: #{object.errors.full_messages.join(',')}"
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
