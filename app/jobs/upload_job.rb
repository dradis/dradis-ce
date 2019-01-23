class UploadJob < ApplicationJob
  queue_as :dradis_upload

  def perform(default_user_id:, file:, plugin_name:, project_id:, uid:)
    logger = Log.new(uid: uid)

    logger.write { "Job id is #{job_id}." }
    logger.write { 'Running Ruby version %s' % RUBY_VERSION }
    logger.write { 'Worker process starting background task.' }

    plugin = plugin_name.constantize

    importer = plugin::Importer.new(
      default_user_id: default_user_id,
      logger: logger,
      plugin: plugin,
      project_id: project_id
    )

    importer.import(file: file)

    logger.write { 'Worker process completed.' }
  end
end
