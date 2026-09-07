module Dradis::Plugins::Echo
  class PromptsController < ApplicationController
    before_action :set_prompt, only: [:show, :edit, :update, :destroy]
    before_action :set_scope, only: [:new]

    def index
      @prompts = Prompt.find_or_seed_for(current_user)
    end

    def new
      @prompt = current_user.prompts.new(scope: @scope)
    end

    def create
      @prompt = current_user.prompts.new
      @prompt.assign_attributes(prompt_params)

      if @prompt.save
        redirect_to prompts_path, notice: 'Prompt was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @prompt.assign_attributes(prompt_params)

      if @prompt.save
        redirect_to prompts_path, notice: 'Prompt was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @prompt.destroy
      redirect_to prompts_path, notice: 'Prompt was successfully destroyed.'
    end

    private
    def prompt_params
      params.require(:prompt).permit(:title, :icon, :prompt, :scope)
    end

    def set_prompt
      @prompt = current_user.prompts.find(params[:id])
    end

    def set_scope
      # Allow nil params[:scope] when creating a new prompt from the index page
      if Prompt::SCOPES.map(&:to_s).include?(params[:scope]) || params[:scope].nil?
        @scope = params[:scope]
      else
        redirect_to prompts_path, alert: 'Something fishy is going on...'
      end
    end
  end
end
