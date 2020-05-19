# Module to execute revision collapsing on a resource
module RevisionCollapsing
  extend ActiveSupport::Concern

  def collapse_revisions(resource, event = RevisionTracking::REVISABLE_EVENTS[:update])
    RevisionCollapserJob.perform_later resource: resource, user_email: PaperTrail.request.whodunnit, event: event
  end
end
