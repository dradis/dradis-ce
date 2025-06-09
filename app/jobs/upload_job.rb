class UploadJob < ApplicationJob
  include Tracked

  queue_as :dradis_upload

  def perform(default_user_id:, file:, plugin_name:, project_id:, state:, uid:)
    logger = Log.new(uid: uid)

    logger.write { "Job id is #{uid}." }
    logger.write { 'Running Ruby version %s' % RUBY_VERSION }
    logger.write { 'Worker process starting background task.' }

    plugin = plugin_name.constantize

    importer = plugin::Importer.new(
      default_user_id: default_user_id,
      logger: logger,
      plugin: plugin,
      project_id: project_id,
      state: state
    )

    importer.import(file: file)

    logger.write { 'Worker process completed.' }

  rescue => exception
    logger.write { "There was an error with the upload: #{exception.message}" }
    if Rails.env.development?
      exception.backtrace.first(10).each do |trace|
        logger.debug { trace }
        sleep(0.2)
      end
    end
    tracker.update_status(state: :failed, message: exception.message)
  end
end
