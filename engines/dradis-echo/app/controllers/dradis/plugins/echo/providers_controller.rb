module Dradis::Plugins::Echo
  class ProvidersController < ApplicationController
    before_action :admin_required, if: -> { defined?(Dradis::Pro) }
    before_action :set_provider, only: [:edit, :update, :destroy]

    def index
      @providers = Provider.all.order(:type)
    end

    def new
      @provider = Provider::Ollama.new
    end

    def create
      type = Provider::ALLOWED_TYPES.find { |t| t == provider_params[:type] } || 'Ollama'
      @provider = Provider.new(provider_params.merge(type: "Dradis::Plugins::Echo::Provider::#{type}"))

      if @provider.save
        redirect_to providers_path, notice: "#{@provider.name} added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      attrs = provider_params.except(:type)
      # remove from params so it's not overwritten if left blank
      attrs.delete(:api_key) if attrs[:api_key].blank?

      if @provider.update(attrs)
        redirect_to providers_path, notice: "#{@provider.name} updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @provider.in_use?
        redirect_to providers_path, alert: "#{@provider.name} is in use and cannot be deleted."
      else
        @provider.destroy
        redirect_to providers_path, notice: "#{@provider.name} removed."
      end
    end

    private

    def admin_required
      unless current_user && current_user.role?(:admin)
        flash[:alert] = 'Access denied.'
        redirect_to main_app.projects_path
      end
    end

    def set_provider
      @provider = Provider.find(params[:id])
    end

    def provider_params
      params.require(:provider).permit(:address, :api_key, :model, :name, :type)
    end
  end
end
