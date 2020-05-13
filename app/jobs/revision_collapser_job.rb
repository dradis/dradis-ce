class RevisionCollapserJob < ApplicationJob
  queue_as :dradis_project

  def perform(resource, event)
    RevisionCollapser.collapse(resource, event)
  end
end
