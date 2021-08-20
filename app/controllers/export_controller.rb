class ExportController < AuthenticatedController
  include ProjectScoped

  before_action :find_plugins, except: [:index, :validation_status]
  before_action :validate_exporter, except: [:index, :validation_status]
  before_action :validate_template, except: [:index, :validation_status]

  def index
  end

  def create
    # We need to pass some params to the plugin's controller. But we're
    # redirecting, so we'll put them in the session.
    # *Warning* can't store too much data here.
    session[:export_manager] = {
      project_id: current_project.id,
      template: @template_file
    }

    # FIXME: check the Routing guide to find a better way.
    action_path = "#{params[:route]}_path"
    redirect_to eval(@exporter::Engine::engine_name).send(action_path)
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
    @logs    = Log.where("uid = ? and id > ?", @log_uid, params[:after].to_i)

    status = Resque::Plugins::Status::Hash.get(@job_id)
    render json: status.reverse_merge({
      logs: @logs,
      validating: nil,
      validators: []
    }).to_json(root: false)
  end

  private

  # The list of available Export plugins. See the dradis_plugins gem.
  def find_plugins
    @plugins = Dradis::Plugins::with_feature(:export).collect do |plugin|
      path = plugin.to_s
      path[0..path.rindex('::')-1].constantize
    end.sort{|a,b| a.name <=> b.name }
  end

  # In case something goes wrong with the export, fail graciously instead of
  # presenting the obscure Error 500 default page of Rails.
  def rescue_action(exception)
    flash[:error] = exception.message
    redirect_to project_upload_manager_path(current_project)
  end

  def templates_dir_for(args={})
    plugin = args[:plugin]
    File.join(::Configuration::paths_templates_reports, plugin::Engine.plugin_name.to_s)
  end

  # Ensure that the requested :uploader is valid
  def validate_exporter
    valid_exporters = {}
    @plugins.each do |plugin|
      valid_exporters[plugin::Engine::plugin_name.to_s] = plugin
    end

    if (params.key?(:plugin) && valid_exporters.keys.include?(params[:plugin]))
      @exporter = valid_exporters[params[:plugin]]
    else
      redirect_to project_export_manager_path(current_project), alert: 'Something fishy is going on...'
    end
  end

  def validate_template
    if params.key?(:template)
      template_name  = params[:template]
      templates_dir  = templates_dir_for(plugin: @exporter)
      @template_file = File.expand_path(File.join(templates_dir, template_name))
      @template_file.starts_with?(templates_dir) && File.exists?(@template_file)
    end
  end
end
