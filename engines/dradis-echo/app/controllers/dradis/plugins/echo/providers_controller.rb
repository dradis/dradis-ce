module Dradis::Plugins::Echo
  class ProvidersController < ApplicationController
    before_action :admin_required, if: -> { defined?(Dradis::Pro) }
    before_action :set_provider, only: [:edit, :update, :destroy]

    helper Dradis::Plugins::Echo::ProvidersHelper

    def index
      @providers = Provider.all.order(:type)
    end

    def new
      type_name = params[:type].presence_in(Provider::ALLOWED_TYPES) || 'Ollama'
      @provider = "Dradis::Plugins::Echo::Provider::#{type_name}".constantize.new
    end

    def create
      attrs = provider_params
      type_short = attrs[:type].presence_in(Provider::ALLOWED_TYPES)
      attrs = attrs.merge(type: "Dradis::Plugins::Echo::Provider::#{type_short}") if type_short
      @provider = Provider.new(attrs)

      if @provider.save
        redirect_to providers_path, notice: "#{@provider.name} added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      attrs = provider_params.except(:type)
      attrs.delete(:api_key) if attrs[:api_key].blank?

      if @provider.update(attrs)
        redirect_to providers_path, notice: "#{@provider.name} updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if helpers.provider_in_use?(@provider)
        usages = helpers.provider_used_by(@provider)
        redirect_to providers_path, alert: "#{@provider.name} is in use by #{usages} and cannot be deleted."
        return
      end

      name = @provider.name
      @provider.destroy
      redirect_to providers_path, notice: "#{name} removed."
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
