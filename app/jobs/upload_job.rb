class UploadJob < ApplicationJob
  queue_as :dradis_upload

  def perform(file:, plugin:, uid:)
    logger = Log.new(uid: uid)

    logger.write{ "Running Ruby version %s" % RUBY_VERSION }
    logger.write{ 'Worker process starting background task.' }

    plugin = plugin_name.constantize

    content_service  = Dradis::Plugins::ContentService.new(plugin: plugin)
    template_service = Dradis::Plugins::TemplateService.new(plugin: plugin)

    importer = plugin::Importer.new(
                logger: logger,
       content_service: content_service,
      template_service: template_service
    )

    importer.import(file: file)

    logger.write{ 'Worker process completed.' }
  end
end
