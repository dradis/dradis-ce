class UploadJob < ApplicationJob
  queue_as :dradis_upload

  def perform(file:, plugin:, uid:)
    logger = Log.new(uid: uid)

    logger.write{ "Running Ruby version %s" % RUBY_VERSION }
    logger.write{ 'Worker process starting background task.' }

    plugin = plugin_name.constantize

    importer = plugin::Importer.new(
      logger: logger,
      plugin: plugin
    )

    importer.import(file: file)

    logger.write{ 'Worker process completed.' }
  end
end
