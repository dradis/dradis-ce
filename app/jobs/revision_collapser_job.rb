class RevisionCollapserJob < ApplicationJob
  queue_as :dradis_project

  def perform(resource)
    RevisionCollapser.collapse(resource)
  end
end
