module Uploaded
  extend ActiveSupport::Concern

  included do
    include UploaderFinder

    before_action :validate_state, only: [:create, :parse]
  end

  private

  def process_upload_background(args = {})
    attachment = args.fetch(:attachment)

    job_logger.write 'Enqueueing job to start in the background.'

    uid = is_api? ? job_logger.id : params[:item_id].to_i

    # NOTE: call the bg job as last thing in the action helps us
    # avoid SQLite3::BusyException when using sqlite and
    # activejob async queue adapter
    UploadJob.create(
      default_user_id: current_user.id,
      file: attachment.fullpath.to_s,
      plugin_name: @uploader.to_s,
      project_id: current_project.id,
      state: @state,
      uid: uid
    )
  end

  def process_upload_inline(args = {})
    attachment = args[:attachment]

    job_logger.write('Small attachment detected. Processing in line.')
    begin
      importer = @uploader::Importer.new(
        default_user_id: current_user.id,
        logger:     job_logger,
        plugin:     @uploader,
        project_id: current_project.id,
        state: @state,
      )

      importer.import(file: attachment.fullpath)
    rescue Exception => e
      # Fail noisily in test mode; re-raise the error so the test fails:
      raise if Rails.env.test?
      job_logger.write('There was a fatal error processing your upload:')
      job_logger.write(e.message)
      if Rails.env.development?
        e.backtrace[0..10].each do |trace|
          job_logger.debug { trace }
          sleep(0.2)
        end
      end
    end
    job_logger.write('Worker process completed.')
  end

  def validate_state
    return if @uploader.to_s.include?('::Projects')

    if Issue.states.keys.include?(params[:state])
      @state = params[:state]
    elsif is_api?
      raise ActiveRecord::RecordNotFound
    else
      redirect_to project_upload_manager_path(current_project), alert: 'Something fishy is going on...'
    end
  end

  def is_api?
    controller_path.include?('api')
  end
end
