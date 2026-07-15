module Dradis::Plugins::Echo
  class Projects::SessionsController < AuthenticatedController
    include EventPublisher
    include ProjectScoped
    include RecordScoping
    layout false

    before_action :set_type
    before_action :set_record, only: [:index, :create]
    before_action :check_turbo_config, only: [:show, :create]
    before_action :set_session, only: [:show]

    def index
      @sessions = Session.for_record(@record).order(created_at: :desc)

      Prompt.seed_default_prompts(current_user) if current_user.prompts.empty?
      @prompts = current_user.prompts.for(@type)
    end

    def show; end

    # Starts a conversation from a saved prompt. The Prompt is read only here, at
    # the controller boundary — we copy its title and never store a FK, so a
    # later edit or deletion of the template can't rewrite history. Scoping the
    # lookup through `for(@type)` honours the Prompt::SCOPES whitelist. The first
    # user Message carries the (Liquid-rendered, possibly edited) prompt text.
    def create
      prompt = current_user.prompts.for(@type).find(params[:prompt_id])

      @session = Session.new(
        agent: Agents::Roslin.instance,
        record: @record,
        title: prompt.title,
        user: current_user
      )
      @session.messages.build(content: params[:prompt], role: :user, user: current_user)
      @session.save!

      @session.request_reply!
      publish_event('echo_session.created', session: { id: @session.id })

      render :show
    end

    private

    def check_turbo_config
      @turbo_status = begin
        ActionCable.server.pubsub.redis_connection_for_subscriptions.ping
        true
      rescue
        false
      end
    end

    def record_params
      params.permit(:id, :prompt, :prompt_id, :project_id, :record, :type)
    end

    def set_record
      raise ActiveRecord::RecordNotFound if @type.blank?

      @record = current_project.send(@type.to_s.pluralize).find(record_params[:record])
    end

    def set_session
      @session = Session.find(record_params[:id])
      @record = scoped_record(@session.record)
    end

    def set_type
      allowed = Prompt::SCOPES.map(&:to_s)
      @type = allowed.include?(record_params[:type]) ? record_params[:type].to_sym : nil
    end
  end
end
