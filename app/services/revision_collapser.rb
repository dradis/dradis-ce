# Revisions get collapsed in three instances:
# - A user has auto-saved: We clean up old auto-saves
# - A user has saved: We collapse previous auto-saves
# - A user has discarded changes: We revert the resource and remove old
#   auto-saves
# "Collapse" is how we refer to removing multiple revisions of auto save. In
# practice it may mean we simply remove old versions and don't infact handle
# any kind of multi-revision-merging at the moment.
class RevisionCollapser
  def self.call(resource)
    last_revision = resource.versions.reorder('created_at DESC').select(:created_at, :event).last
    latest_timestamp = last_revision.event == Activity::VALID_ACTIONS[:autosave] ? last_revision.created_at : resource.updated_at

    resource.versions.where(event: Activity::VALID_ACTIONS[:autosave]).where('created_at < ?', latest_timestamp).destroy_all
  end
end
