# Wraps around an instance of `PaperTrail::Version` (where event==update) and
# lets us show a diff
class DiffedRevision

  def initialize(revision, record)
    raise 'undiffable revision' unless revision.event == 'update'
    @revision = revision
    @record   = record
  end

  def diff
    @diff ||= Differ.diff_by_line(
                after[content_attribute],
                before_content
              )
  end

  def last_updated_at
    before['updated_at'].strftime(RevisionsHelper::DATE_FORMAT)
  end

  def previous_action
    @revision.previous.event
  end

  def previous_author
    @revision.previous.whodunnit
  end

  def this_author
    @revision.whodunnit
  end

  def updated_at
    after['updated_at'].strftime(RevisionsHelper::DATE_FORMAT)
  end

  private

  def before
    # Version#object is the state of the object *before* the change was made.
    @before ||= YAML.load(@revision.object)
  end

  def before_content
    @revision.previous.event == 'create' ? before[content_attribute].gsub("\n", "\r\n") : before[content_attribute]
  end

  def after
    # Note: PaperTrail::Version#object will return `nil` if its event type
    # is `create` - but in theory, @revision.next below should always return
    # a version with event type 'update' or 'destroy'. If it doesn't, and
    # this method crashes, then bad data has snuck into your DB somehow.
    @after ||= if next_revision = @revision.next
                 YAML.load(next_revision.object)
               else
                 @record.attributes
               end
  end

  def content_attribute
    case @record
    when Issue, Note; 'text' # FIXME - ISSUE/NOTE INHERITANCE
    when Evidence; 'content'
    end
  end

end
