class RevisionCollapserJob < ApplicationJob
  queue_as :dradis_project

  def perform(resource)
    RevisionCollapser.collapse(resource, RevisionTracking::REVISABLE_EVENTS[:update])
  end
end
