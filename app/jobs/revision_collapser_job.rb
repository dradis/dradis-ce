class RevisionCollapserJob < ApplicationJob
  queue_as :dradis_project

  def perform(resource, whodunnit, event)
    RevisionCollapser.collapse(resource, whodunnit, event)
  end
end
