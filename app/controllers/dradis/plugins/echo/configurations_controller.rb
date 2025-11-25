module Dradis::Plugins::Echo
  class ConfigurationsController < AuthenticatedController
    def index
      @configuration_form = ConfigurationForm.from_storage

      @is_default_model = Engine.settings.all.find { |c| c[:name] == :model }[:default]
    end

    def update
      @configuration_form = ConfigurationForm.new(configuration_params)

      if @configuration_form.save
        redirect_to configurations_path, notice: 'Updated configuration successfully'
      else
        flash[:alert] = 'Invalid settings'
        render action: :index
      end
    end

    private

    def configuration_params
      params.require(:configuration_form).permit(:address, :model)
    end
  end
end
