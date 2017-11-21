class MultiDestroyJob < ApplicationJob
  include ActivityTracking

  queue_as :dradis_project

  def perform(author_email:, ids:, klass:, uid:)
    # FIXME: migrate logs#uid to uuid ?
    logger = Log.new(uid: uid)

    items = klass.constantize.where(id: ids)

    logger.write do
      "Deleting #{items.count} #{klass.pluralize}"
    end

    ActiveRecord::Base.transaction do
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
