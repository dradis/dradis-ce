# UPGRADE: we don't need to deal with vendorized configurations

# Internal application Configuration settings are handled through this
# REST-enabled controller.
class ConfigurationsController < ProjectScopedController
  before_filter :find_or_initialize_config, except: [ :index ]

  # Get all the Configuration objects.
  def index
    @configs = all_configurations
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # Update the value of a Configuration object or gemified plugin setting.
  def update
    respond_to do |format|
      format.html { head :method_not_allowed }

      if @config && @config.update_attributes(params[:config])
        format.js { render json: @config.to_json }
      elsif @plugin
        @plugin.settings.update_settings(params[:setting])
        @is_default = @plugin.settings.is_default?(params[:setting].keys.first, params[:setting].values.first)
        format.js { render json: { setting_is_default: @is_default }.to_json }
      else
        format.js { render json: @config.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  # DEPRECATED
  # TODO: Remove when all plugins have been gemified.
  # Create a new Configuration object and store it in the database.
  def create
    respond_to do |format|
      format.html { head :method_not_allowed }
      if @config.save
        headers['Location'] = configuration_url(@config)
        format.js { render json: @config.to_json, status: :created }
      else
        format.js { render json: @config.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  # DEPRECATED
  # TODO: Remove when all plugins have been gemified.
  # Retrieve a Configuration object. Only supports XML format.
  def show
    respond_to do |format|
      format.html { head :method_not_allowed }
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
    # configurations = vendorized.zip(gemified).flatten
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

  # DEPRECATED
  # TODO: Remove when all plugins have been gemified.
  # This filter locates a Configuration object based on the :id passed as a
  # parameter in the request. If the :id is invalid, it delegates to find_plugin
  def find_or_initialize_config
    if params[:id]
      if @config = params[:id].to_s =~ /\A[0-9]+\z/ ? ::Configuration.find(params[:id]) : ::Configuration.find_by_name(params[:id])
        return true
      else
        find_plugin
      end
    else
      @config = ::Configuration.new(params[:config])
    end
  end

end
