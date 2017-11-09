class DestroyJob < ApplicationJob
  include ActivityTracking

  queue_as :dradis_project

  def perform(items:, author_email:, uid:)
    # FIXME: migrate logs#uid to uuid ?
    logger = Log.new(uid: uid)
    logger.write do
      "Deleting #{items.count} #{items.first.class.to_s.pluralize}"
    end

    Note.transaction do
      items.each do |item|
        if item.destroy
          track_destroyed(item, User.new(email: author_email))
          logger.write { "Deleted #{item.class} #{item.id}..." }
        end
      end
    end

    logger.write { 'Worker process completed.' }
  end
end
