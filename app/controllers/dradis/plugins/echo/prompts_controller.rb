module Dradis::Plugins::Echo
  class PromptsController < AuthenticatedController
    before_action :set_prompt, only: [:show, :edit, :update, :destroy]

    layout false

    def index
      @prompts = current_user.prompts
    end

    def new
      @prompt = current_user.prompts.new
    end

    def create
      @prompt = current_user.prompts.new
      @prompt.assign_attributes(prompt_params)

      if @prompt.save
        redirect_to prompts_path, notice: 'Prompt was successfully created.'
      else
        render :new
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
      params.require(:prompt).permit(:title, :icon, :prompt)
    end

    def set_prompt
      @prompt = current_user.prompts.find(params[:id])
    end
  end
end
