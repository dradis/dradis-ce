class RevisionCollapserJob < ApplicationJob
  queue_as :dradis_project

  def perform(resource:, user_email:, event:)
    RevisionCollapser.collapse(resource: resource, user_email: user_email, event: event)
  end
end
