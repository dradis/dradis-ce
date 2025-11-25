module Dradis::Plugins::Echo
  class ConfigurationsController < AuthenticatedController
    before_action :set_configurations

    def index
      @is_default_model = @configurations.find { |c| c[:name] == :model }[:default]
    end

    def update
      if validate_address(configuration_params[:address]) &&
          Engine.settings.update_settings(configuration_params)

        redirect_to configurations_path, notice: 'Updated configuration successfully'
      else
        flash[:alert] = 'Invalid settings'
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

    def validate_address(string)
      uri = URI.parse(string)
      uri.host.present?
    rescue URI::InvalidURIError
      false
    end
  end
end
