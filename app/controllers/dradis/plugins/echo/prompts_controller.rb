require 'ollama-ai'

module Dradis::Plugins::Echo
  class PromptsController < AuthenticatedController
    include ProjectScoped
    layout false

    before_action :check_turbo_config, only: [:index]

    def index
      @type = set_type
      @prompts = Prompt.default.key?(@type) ? Prompt.default[@type] : []
      @record = params[:record].to_i
    end

    def show
      @type = set_type
      @record_id = params[:record]
      @interaction_id = SecureRandom.hex(20)
      @response_id = SecureRandom.hex(10)

      @template = Prompt.by_id(params[:id], klass: @type)

      EchoJob.set(wait: 2.seconds).perform_later(
        prompt_id: params[:id],
        klass: @type,
        record_id: @record_id,
        interaction_id: @interaction_id,
        response_id: @response_id
      )
    end

    private

    # Echo requires Turbo, and Turbo requires:
    #   1. ActionCable to be configured using the :redis adapter.
    #   2. for Redis to be running.
    def check_turbo_config
      @turbo_status = begin
        ActionCable.server.pubsub.redis_connection_for_subscriptions.ping
        true
      rescue
        false
      end
    end

    def set_type
      allowed = Prompt.default.keys.map(&:to_s)
      allowed.include?(params[:type]) ? params[:type].to_sym : nil
    end
  end
end
