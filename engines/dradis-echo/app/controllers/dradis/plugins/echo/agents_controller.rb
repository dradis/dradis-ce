module Dradis::Plugins::Echo
  class AgentsController < ApplicationController
    before_action :admin_required, if: -> { defined?(Dradis::Pro) }
    before_action :set_agent, only: [:edit, :update]
    before_action :set_providers, only: [:edit, :update]

    def index
      @agents = Agent.includes(:provider).all.order(:name)
    end

    def edit; end

    def update
      if @agent.update(agent_params)
        redirect_to agents_path, notice: "#{@agent.name} updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def admin_required
      unless current_user && current_user.role?(:admin)
        flash[:alert] = 'Access denied.'
        redirect_to main_app.projects_path
      end
    end

    def agent_params
      permitted = params.require(:agent).permit(
        :enabled, :model_override, :provider_id,
        env_keys: [], env_values: []
      )
      keys = permitted.delete(:env_keys) || []
      values = permitted.delete(:env_values) || []
      permitted.merge(env: keys.zip(values).reject { |k, _| k.blank? }.to_h)
    end

    def set_agent
      # Avoid params[:id] until we allow :user Agents
      agent_id = Agents::Roslin.id
      @agent = Agent.find(agent_id)
    end

    def set_providers
      @providers = Provider.all.order(:type)
    end
  end
end
