module Dradis::Plugins::Echo
  class ProvidersController < ApplicationController
    before_action :admin_required, if: -> { defined?(Dradis::Pro) }
    before_action :set_provider, only: [:edit, :update, :destroy]
    before_action :set_provider_type, only: [:new, :create]

    def index
      @providers = Provider.includes(:agents).all.order(:type)
    end

    def new
      @provider = @provider_type.new(
        address: @provider_type.default_address,
        model: @provider_type.default_model,
        name: @provider_type.name.demodulize
      )
    end

    def create
      @provider = Provider.new(provider_params.except(:type).merge(type: @provider_type.name))

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
      if @provider.destroy
        redirect_to providers_path, notice: "#{@provider.name} removed."
      else
        redirect_to providers_path, alert: "#{@provider.name} is in use and cannot be deleted."
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

    def set_provider_type
      type_name = params[:type].presence || params.dig(:provider, :type)
      type = Provider::ALLOWED_TYPES.find { |t| t == type_name } || 'Ollama'
      @provider_type = "Dradis::Plugins::Echo::Provider::#{type}".constantize
    end

    def provider_params
      params.require(:provider).permit(:address, :api_key, :model, :name, :type)
    end
  end
end
