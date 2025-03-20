require 'ollama-ai'

module Dradis::Plugins::Echo
  class PromptsController < AuthenticatedController
    include ProjectScoped
    layout false

    def index
      @type = set_type
      @prompts = Prompt.default.key?(@type) ? Prompt.default[@type] : []
      @record = params[:record].to_i
    end

    def show
      @type = set_type
      @record_id = params[:record]
      @interaction_id = SecureRandom.hex(20)
      EchoJob.perform_later(params[:id], @record_id, @interaction_id)
    end

    private
    def set_type
      allowed = Prompt.default.keys.map(&:to_s)
      allowed.include?(params[:type]) ? params[:type].to_sym : nil
    end
  end
end
