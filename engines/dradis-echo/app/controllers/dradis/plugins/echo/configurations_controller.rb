module Dradis::Plugins::Echo
  class ConfigurationsController < ApplicationController
    before_action :admin_required, if: -> { defined?(Dradis::Pro) }

    def index
      @configuration_form = ConfigurationForm.from_storage
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

    def admin_required
      unless current_user && current_user.role?(:admin)
        flash[:notice] = 'Access denied.'
        redirect_to main_app.projects_path
      end
    end

    def configuration_params
      params.require(:configuration_form).permit(:roslin_ollama_address, :roslin_ollama_model)
    end
  end
end
