module Dradis::Plugins::Echo
  class Projects::PromptsController < AuthenticatedController
    include ProjectScoped
    layout false

    before_action :check_turbo_config, only: [:index]
    before_action :set_type
    before_action :set_record, except: [:create]

    def index
      Prompt.seed_default_prompts(current_user) if current_user.prompts.empty?

      @prompts = current_user.prompts.for(@type)
    end

    def show
      @template = current_user.prompts.find(params[:id])
      @prompt = params[:prompt]
      @interaction_id = SecureRandom.hex(20)
      @response_id = SecureRandom.hex(10)
    end

    def create
      EchoJob.perform_later(
        prompt: params[:prompt],
        interaction_id: params[:interaction_id],
        response_id: params[:response_id]
      )

      head :ok
    end

    private

    def liquid_parse(template)
      assigns = { 'issue' => IssueDrop.new(@record) }

      options = {
        filters: [],
        strict_filters: true,
        strict_variables: true
      }

      Liquid::Template.parse(template).render(assigns, options)
    end
    helper_method :liquid_parse

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

    def set_record
      @record = current_project.send(@type.to_s.pluralize).find(record_params[:record])
    end

    def set_type
      allowed = Prompt::SCOPES.map(&:to_s)
      @type = allowed.include?(record_params[:type]) ? record_params[:type].to_sym : nil
    end
  end
end
