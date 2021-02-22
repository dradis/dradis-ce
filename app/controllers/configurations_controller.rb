# Internal application Configuration settings are handled through this
# REST-enabled controller.
class ConfigurationsController < AuthenticatedController
  include ProjectScoped

  before_action :find_plugin, except: [ :index ]

  def index
    @configs = all_configurations
    @outdated_plugins = Dradis::Plugins.outdated_engines
  end

  def update
    respond_to do |format|
      format.html { head :method_not_allowed }

      format.js do
        if @plugin.settings.update_settings(params[:setting])
          @is_default = @plugin.settings.is_default?(params[:setting].keys.first, params[:setting].values.first)
          render json: { setting_is_default: @is_default }.to_json
        else
          render json: @config.errors.to_json, status: :unprocessable_entity
        end
      end
    end
  end

  private
  def all_configurations
    configurations = Dradis::Plugins.list.map do |plugin|
      {
        klass:    plugin.name.to_s,
        name:     plugin.name.gsub(/^Dradis::Plugins::/, '').gsub(/::Engine$/, ''),
        type:     'gemified',
        settings: plugin.settings.all
      }
    end
    configurations = configurations.reject{ |c| c[:settings].empty? }
    configurations = configurations.sort_by{ |c| c[:name] }
  end

  # This filter locates the Dradis::Plugins subclass
  # for which we're updating the settings using the :id param.
  # If no plugin is found, an error page is rendered.
  def find_plugin
    if params[:id]
      class_name = "Dradis::Plugins::#{ params[:id].camelcase }::Engine"
      @plugin = class_name.constantize if all_configurations.map{ |c| c[:klass] }.include?(class_name)
    end
    if @plugin.nil?
      raise ActionController::RoutingError.new('Not Found')
    else
      return true
    end
  end
end
