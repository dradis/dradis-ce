class CreateNotificationsJob < ApplicationJob
  include ActivityTracking

  queue_as :dradis_project

  def perform(comment:)
    # TODO: find followers, create notifications
  end
end
