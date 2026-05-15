module Dradis::Plugins::Echo
  class ConfigurationsController < ApplicationController
    before_action :admin_required, if: -> { defined?(Dradis::Pro) }
    before_action :set_providers, only: [:index, :update]

    def index
      @configuration_form = ConfigurationForm.from_storage
    end

    def update
      @configuration_form = ConfigurationForm.new(configuration_params)

      if @configuration_form.save
        redirect_to configurations_path, notice: 'Updated configuration successfully'
      else
        flash.now[:alert] = @configuration_form.errors.full_messages.to_sentence
        render action: :index
      end
    end

    private

    def admin_required
      unless current_user && current_user.role?(:admin)
        flash[:alert] = 'Access denied.'
        redirect_to main_app.projects_path
      end
    end

    def configuration_params
      # each agent injects its own permitted params, ie:
      # { roslin: [:enabled, :provider_id, :issue_interaction_enabled, ...] }
      permitted = ConfigurationForm.agents.each_with_object({}) do |agent, permitted_params|
        permitted_params[agent.form_key.to_sym] = agent::ConfigurationForm.permitted_params
      end
      params.require(:configuration_form).permit(permitted)
    end

    def set_providers
      @providers = Provider.all.order(:type)
    end
  end
end
