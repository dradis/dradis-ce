module Dradis::Plugins::Echo
  class ProvidersController < ApplicationController
    before_action :admin_required, if: -> { defined?(Dradis::Pro) }
    before_action :set_provider, only: [:edit, :update, :destroy]

    def new
      type = Provider.subclasses.find { |c| c.name.demodulize == params[:type] } || Provider::Ollama
      @provider = type.new
    end

    def create
      @provider = Provider.new(provider_params)

      if @provider.save
        redirect_to configurations_path, notice: "#{@provider.name} added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit;end

    def update
      attrs = provider_params.except(:type)
      # remove from params so it's not overwritten if left blank
      attrs.delete(:api_key) if attrs[:api_key].blank?

      if @provider.update(attrs)
        redirect_to configurations_path, notice: "#{@provider.name} updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @provider.destroy
        redirect_to configurations_path, notice: 'Provider removed.'
      else
        redirect_to configurations_path, notice: "Error removing provider: #{@provider.errors.full_messages.join('; ')}"
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
