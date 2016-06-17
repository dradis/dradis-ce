# Resque background worker to process files uploaded via the Upload Manager.
#
# This worker requires the following options:
#   plugin: Upload Plugin that needs to process the file,
#     file: Full path to the file to be processed,
#      uid: uuid for this job

class UploadProcessor < BaseWorker
  @queue = :dradis_upload

  def perform_delegate
    file        = options['file']
    plugin_name = options['plugin']
    uid         = options['uid']

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
