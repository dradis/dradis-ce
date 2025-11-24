module Dradis::Plugins::Echo
  class ConfigurationsController < AuthenticatedController
    before_action :set_configurations

    def index
      @model = @configurations.find { |c| c[:name] == :model }
    end

    def update
      if Engine.settings.update_settings(configuration_params)
        redirect_to configurations_path, notice: 'Updated configuration successfully'
      else
        render :index
      end
    end

    private

    def configuration_params
      params.permit(:address, :model)
    end

    def set_configurations
      @configurations = Engine.settings.all
    end
  end
end
