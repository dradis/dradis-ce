# Revisions get collapsed in three instances:
# - A user has auto-saved: We clean previous old auto-saves
# - A user has saved: We clean up all auto-saves
# - A user has discarded changes: We revert the resource and remove old
#   auto-saves
#
# "Collapse" is how we refer to removing multiple revisions of auto save while
# persisting the cumulative changes. In practice it may mean we simply remove
# old versions and persist the original state.
#
# Papertrail saves the *original* state of the record. When we compare
# it in a diff, we want to compare the current state whether it's an autosave or
# update to the original state before auto-save started. The incremental changes
# can be discarded with out concern. Orignal <=> Current is what's important.
# Anytime the previous revision is an auto-save we want to carry the original
# state forward so we can always have it accessible to compare against. This
# happens when the new revision is an update, or autosave.
class RevisionCollapser
  def self.call(resource)
    return unless resource.versions.any? # Lots of specs run without versioning

    last_revision = resource.versions.reorder('created_at DESC').first
    # Just in case there is more than a single autosave take the oldest.
    previous_autosave = resource.versions.where(event: Activity::VALID_ACTIONS[:autosave]).
                                 where.not(id: last_revision).reorder('created_at ASC').first

    if resource.class::REVISABLE_EVENTS.include?(last_revision.event) && previous_autosave
      last_revision.update(object: previous_autosave.object)
    end

    resource.versions.
      where(event: Activity::VALID_ACTIONS[:autosave]).
      where('created_at < ?', last_revision.created_at).destroy_all
  end

  def self.discard_and_revert(resource)
    return unless resource.versions.any? # Lots of specs run without versioning

    last_revision = resource.versions.reorder('created_at DESC').first

    if last_revision.event == Activity::VALID_ACTIONS[:autosave]
      # Turn papertrail off so it doesn't create a new revision when we restore
      # the original. The restore is technically just an update, and we would
      # end up with an 'Update' revision if we don't turn it off.
      PaperTrail.request(enabled: false) do
        last_revision.reify.save
      end

      resource.versions.where(event: Activity::VALID_ACTIONS[:autosave]).destroy_all
    end
  end
end
