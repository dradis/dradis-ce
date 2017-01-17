# Wraps around an instance of `PaperTrail::Version` (where event==destroy) and
# lets us a) recover the deleted item and b) load all soft-deleted items so we
# can show them on the trash page.
class RecoverableRevision
  attr_reader :object, :version

  delegate :cache_key, to: :version
  delegate :errors, to: :object


  # -- Class Methods --------------------------------------------------------
  # Load all 'destroy' revisions which represent an object which is in the
  # trash and can be recovered (or perma-deleted).
  #
  # Note that an object can be deleted and recovered multiple times, in which
  # case it will have multiple 'destroy' revisions. This method will only
  # return the most recent 'destroy' revision.
  def self.all
    # Based on https://leonid.shevtsov.me/post/how-to-use-papertrail-for-soft-deletetion/
    #
    # This isn't ideal because it makes multiple SQL calls, but it will do.
    # See discussion at https://github.com/dradis/dradis-ce/pull/45#discussion_r77555665
    #
    # No need to include Issue in this array because Issue revisions have
    # their item_type saved as `Note`, not `Issue`. FIXME - ISSUE/NOTE INHERITANCE
    ids = [Evidence, Note].flat_map do |model|
      table_name = model.table_name
      versions = PaperTrail::Version.where(event: 'destroy', item_type: model.to_s).
        joins("LEFT JOIN #{table_name} ON item_id=#{table_name}.id").
        where("#{table_name}.id IS NULL"). # avoid showing deleted objects
        order('id DESC')

      versions.group_by(&:item_id).map { |_,v| v.first.id }
    end
    PaperTrail::Version.where(id: ids.uniq).select("versions.*").order('created_at DESC').map do |version|
      new(version)
    end
  end

  def self.find(id)
    new(PaperTrail::Version.where(event: :destroy).find_by!(id: id))
  end


  # -- Instance Methods -----------------------------------------------------
  def initialize(version)
    @version = version
    @object  = version.reify
  end

  def recover
    # If we're recovering an issue, revision.reify will return an instance
    # of `Note`, because `revision.reify.item_type == "Note"`. This won't prevent
    # the issue from being recovered correctly (because `revision.reify.node_id
    # == Node.issue_library.id`), it will break the activity feed, because
    # track_activity will create an Activity with `trackable_type == "Note"`,
    # not `trackable_type == "Issue"`.  So if revision.reify returns a Note
    # which should be an issue, convert it to an instance of Issue:
    #
    # FIXME - ISSUE/NOTE INHERITANCE
    if @object.instance_of?(Note) && @object.node_id == Node.issue_library.id
      @object = Issue.new(@object.attributes)
    end

    # If @object's node was destroyed, assign it to a new node.
    @object.node = Node.recovered if !Node.exists?(@object.node_id)

    # If object is evidence and its issue doesn't exist any more, recover the issue.
    if @version.item_type == 'Evidence' && !Note.exists?(@object.issue_id)
      issue_revision = PaperTrail::Version.find_by(
        event: 'destroy', item_type: 'Note', item_id: @object.issue_id
      )
      # A destroy revision should always be present, but just in case.
      if issue_revision
        issue_object         = issue_revision.reify
        issue_object.node_id = Node.issue_library.id
        issue_object.save!
        issue_object.touch
        @object.issue_id = issue_object.id
      end
    end

    @object.save
    @object.touch
  end

  def type
    if object.is_a?(Note)
      return 'Issue'       if object.node_id == Node.issue_library.id
      return 'Methodology' if object.node_id == Node.methodology_library.id
      return 'Note'
    else
      object.class.name.humanize
    end
  end

end
