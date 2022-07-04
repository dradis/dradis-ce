# The UploadController provides access to the different upload plugins that
# have been deployed in the dradis server.
#
# Each upload plugin will include itself in the Plugins::Upload module and this
# controller will include it so all the functionality provided by the different
# plugins is exposed.
#
# A convenience list method is provided that will return all the currently
# loaded plugins of this category.
class UploadController < AuthenticatedController
  include ProjectScoped

  # UPGRADE
  # include Plugins::Upload

  before_action :load_uploaders
  before_action :validate_files, only: [:create]

  def index
    @last_job = Log.new.uid
  end

  # TODO: this would overwrite an existing file with the same name.
  # See AttachmentsController#create
  def create
    @files = []

    params[:files].each do |file|
      filename = CGI::escape file.original_filename
      extension = File.extname(filename).downcase

      # add the file as an attachment
      attachment = Attachment.new(filename, node_id: current_project.plugin_uploads_node.id)
      attachment << file.read
      attachment.save

      @files << { name: attachment.filename, uploader: @uploaders[extension][:name] }.to_json
    end

    @success = true
    @item_id = params[:item_id].to_i
  end

  def parse
    params[:files].each do |file|
      file = JSON.parse(file)
      attachment = Attachment.find(file["name"], conditions: { node_id: current_project.plugin_uploads_node.id })

      # Skip to next file if uploader doesn't match supported versions.
      if @uploaders.values.pluck(:name).exclude?(file["uploader"])
        job_logger.write "Invalid uploader provided: #{file["uploader"]}! Skipping to next file."
        next
      end

      # Files smaller than 1Mb are processed inlined, others are
      # processed in the background via a Redis worker.
      #
      # In Production, play it save and use the worker (the Rules Engine can
      # cause the processing of a small file to time out).
      #
      # In Development and testing, if the file is small, process in line.
      if Rails.env.production? || (File.size(attachment.fullpath) > 1024*1024)
        process_upload_background(attachment: attachment, uploader: file["uploader"])
      else
        process_upload_inline(attachment: attachment, uploader: file["uploader"])
      end
    end

    # Nothing to do, the client-side JS will poll ./status for updates
    # from now on
    head :ok
  end

  private

  def job_logger
    @job_logger ||= Log.new(uid: params[:item_id].to_i)
  end

  def process_upload_background(args={})
    attachment = args.fetch(:attachment)
    uploader = args[:uploader]

    job_logger.write 'Enqueueing job to start in the background.'

    # NOTE: call the bg job as last thing in the action helps us
    # avoid SQLite3::BusyException when using sqlite and
    # activejob async queue adapter
    UploadJob.perform_later(
      default_user_id: current_user.id,
      file: attachment.fullpath.to_s,
      plugin_name: uploader,
      project_id: current_project.id,
      uid: params[:item_id].to_i
    )
  end

  def process_upload_inline(args={})
    attachment = args[:attachment]
    uploader = args[:uploader].constantize

    job_logger.write("Small attachment detected. Processing file #{attachment.filename} in line.\n")
    begin
      importer = uploader::Importer.new(
        default_user_id: current_user.id,
        logger:     job_logger,
        plugin:     uploader,
        project_id: current_project.id
      )

      importer.import(file: attachment.fullpath)
    rescue Exception => e
      # Fail noisily in test mode; re-raise the error so the test fails:
      raise if Rails.env.test?
      job_logger.write('There was a fatal error processing your upload:')
      job_logger.write(e.message)
      if Rails.env.development?
        e.backtrace[0..10].each do |trace|
          job_logger.debug{ trace }
          sleep(0.2)
        end
      end
    end
    job_logger.write("Worker process completed for #{attachment.filename}.\n")
  end

  def load_uploaders
    @uploaders ||= Attachment::SUPPORTED_PLUGINS
  end

  # Ensure that the requested :uploader is valid and has been included in the
  # Plugins::Upload mixin
  def validate_files
    params[:files].each do |file|
      extension = File.extname(file.path).downcase

      if @uploaders.keys.exclude?(extension)
        redirect_to project_upload_manager_path(current_project), alert: 'Something fishy is going on...'
      end
    end
  end
end
