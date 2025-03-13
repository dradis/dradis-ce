require 'ollama-ai'

module Dradis::Plugins::Echo
  class PromptsController < AuthenticatedController
    include ProjectScoped

    def show
      @prompt_id = SecureRandom.hex(20)
      EchoJob.perform_later(params[:id], @prompt_id)
      render layout: false
    end
  end
end
