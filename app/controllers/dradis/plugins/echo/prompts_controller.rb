module Dradis::Plugins::Echo
  class PromptsController < AuthenticatedController
    include ProjectScoped
    layout false

    before_action :check_turbo_config, only: [:index]
    before_action :set_type

    def index
      @prompts = Prompt.default.key?(@type) ? Prompt.default[@type] : []
      @record = record_params[:record].to_i
    end

    def show
      @template = Prompt.by_id(record_params[:id], klass: @type)
      @record = current_project.send(@type.to_s.pluralize).find(record_params[:record])

      @interaction_id = SecureRandom.hex(20)
      @response_id = SecureRandom.hex(10)

      # EchoJob.set(wait: 2.seconds).perform_later(
      EchoJob.perform_later(
        prompt_id: record_params[:id],
        klass: @type,
        record_id: @record.id,
        interaction_id: @interaction_id,
        response_id: @response_id
      )
    end

    private

    def record_params
      params.permit(:id, :type, :project_id, :record)
    end

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
      @type = allowed.include?(record_params[:type]) ? record_params[:type].to_sym : nil
    end
  end
end
