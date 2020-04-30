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

  before_action :find_uploaders
  before_action :validate_uploader, only: [:create, :parse]

  def index
    @last_job = Log.new.uid
    # Build the issue states collection for the form select
    @issue_states = Issue.states.map do |state, state_id|
      state = state == 'review' ? 'Ready for Review' : state.capitalize
      [state, state_id]
    end

    uploaders_for_select
  end

  # TODO: this would overwrite an existing file with the same name.
  # See AttachmentsController#create
  def create
    filename = CGI::escape params[:file].original_filename
    # add the file as an attachment
    @attachment = Attachment.new(filename, node_id: current_project.plugin_uploads_node.id)
    @attachment << params[:file].read
    @attachment.save

    @item_id = params[:item_id].to_i
    @state  = validate_issue_state
    @success = true
    flash.now[:notice] = "Successfully uploaded #{ filename }"
  end

  def parse
    attachment = Attachment.find(params[:file], conditions: { node_id: current_project.plugin_uploads_node.id })

    # Files smaller than 1Mb are processed inlined, others are
    # processed in the background via a Redis worker.
    #
    # In Production, play it save and use the worker (the Rules Engine can
    # cause the processing of a small file to time out).
    #
    # In Development and testing, if the file is small, process in line.
    if Rails.env.production? || (File.size(attachment.fullpath) > 1024*1024)
      process_upload_background(attachment: attachment)
    else
      process_upload_inline(attachment: attachment)
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

    job_logger.write 'Enqueueing job to start in the background.'

    # NOTE: call the bg job as last thing in the action helps us
    # avoid SQLite3::BusyException when using sqlite and
    # activejob async queue adapter
    UploadJob.perform_later(
      default_user_id:  current_user.id,
      file:             attachment.fullpath.to_s,
      plugin_name:      @uploader.to_s,
      project_id:       current_project.id,
      state:            validate_issue_state,
      uid:              params[:item_id].to_i
    )
  end

  def process_upload_inline(args={})
    attachment = args[:attachment]

    job_logger.write('Small attachment detected. Processing in line.')
    begin
      importer = @uploader::Importer.new(
        default_user_id: current_user.id,
        logger:     job_logger,
        plugin:     @uploader,
        project_id: current_project.id,
        state:      validate_issue_state
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
    job_logger.write('Worker process completed.')
  end

  def find_uploaders
    # :upload plugins can define multiple uploaders
    @uploaders ||= Dradis::Plugins::with_feature(:upload).
                     collect(&:uploaders).
                     flatten
  end

  def uploaders_for_select
    @uploaders_for_select ||=
      @uploaders.map do |uploader|
        base_name = uploader.name.demodulize
        if base_name == 'Package' || base_name == 'Template'
          base_name = "Dradis #{base_name}"
        end
        [base_name, uploader.name]
      end.sort { |a, b| a <=> b }
  end

  def validate_issue_state
    if params[:state] && Issue.states.values.include?(params[:state].to_i)
      params[:state].to_i
    else
      Issue.states[:published]
    end
  end

  # Ensure that the requested :uploader is valid and has been included in the
  # Plugins::Upload mixin
  def validate_uploader
    valid_uploaders = @uploaders.collect(&:name)

    if (params.key?(:uploader) && valid_uploaders.include?(params[:uploader]))
      @uploader = params[:uploader].constantize
    else
      redirect_to project_upload_manager_path(current_project), alert: 'Something fishy is going on...'
    end
  end

end
