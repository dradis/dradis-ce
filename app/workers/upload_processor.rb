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
    project_id  = options['project_id']
    uid         = options['uid']

    logger = Log.new(uid: uid)

    project = Project.find(project_id)

    Activity.set_project_scope(project_id)
    Evidence.set_project_scope(project.id)
    Issue.set_project_scope(project.id)
    Node.set_project_scope(project.id)
    Note.set_project_scope(project.id)
    Tag.set_project_scope(project.id)

    logger.write{ "Running Ruby version %s" % RUBY_VERSION }
    logger.write( "Project: %s" % project.name )

    logger.write{ 'Worker process starting background task.' }

    plugin = plugin_name.constantize

    # Detect new-style gemified plugins
    if plugin::constants::include?(:Importer)
      content_service = Dradis::Pro::Plugins::ContentService.new(plugin: plugin)
      template_service = Dradis::Pro::Plugins::TemplateService.new(plugin: plugin)

      importer = plugin::Importer.new(
                  logger: logger,
         content_service: content_service,
        template_service: template_service
      )

      importer.import(file: file)
    else
      plugin::import(file: file, logger: logger)
    end
    logger.write{ 'Worker process completed.' }
  end
end
