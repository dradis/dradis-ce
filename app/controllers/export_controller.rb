class ExportController < AuthenticatedController
  include ProjectScoped

  def index
  end

  # Runs a pre-export validation of the contents of the project
  def validate
    @validators = Dradis::Pro::Plugins::Export::Validators::BaseValidator.descendants

    logger = Log.new
    @log_uid = logger.uid

    @job_id = ProjectValidator.create(
      plugin: AdvancedWordExport.name,
      template: params[:template],
      uid: @log_uid
    )

    logger.write("Enqueueing pre-export validation job to start in the background. Job id is #{ @log_uid }")
  end

  def validation_status
    @log_uid = params[:log_uid].to_i
    @job_id  = params[:job_id]
    @logs    = Log.where('uid = ? and id > ?', @log_uid, params[:after].to_i)

    status = Resque::Plugins::Status::Hash.get(@job_id)
    render json: status.reverse_merge({
      logs: @logs,
      validating: nil,
      validators: []
    }).to_json(root: false)
  end

  private

  # In case something goes wrong with the export, fail graciously instead of
  # presenting the obscure Error 500 default page of Rails.
  def rescue_action(exception)
    flash[:error] = exception.message
    redirect_to project_upload_manager_path(current_project)
  end
end
