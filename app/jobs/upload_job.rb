class UploadJob
  include Resque::Plugins::Status

  @queue = :dradis_upload

  def perform
    default_user_id = options['default_user_id']
    file = options['file']
    plugin_name = options['plugin_name']
    project_id = options['project_id']
    state = options['state']
    uid = options['uid']

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

    completed
  rescue => exception
    logger.write { "There was an error with the upload: #{exception.message}" }
    if Rails.env.development?
      exception.backtrace.first(10).each do |trace|
        logger.debug { trace }
        sleep(0.2)
      end
    end

    failed('message' => "There was an error with the upload: #{exception.message}")
  end
end
