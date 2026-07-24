module Dradis::Plugins::Echo
  class Projects::SessionsController < AuthenticatedController
    include EventPublisher
    include ProjectScoped
    include RecordScoping
    include TurboConfigCheck
    layout false

    before_action :set_type, only: [:create, :index]
    before_action :set_record, only: [:create, :index]
    before_action :check_turbo_config, only: [:show, :create]
    before_action :set_session, only: [:show]

    # Lists the record's past sessions plus the prompts available to start a new
    # one. Roslin-disabled and prompts empty-state warnings are handled by the
    # view.
    def index
      @sessions = Session.for_record(@record)
      @prompts = current_user.prompts.for(@type)
    end

    def show; end

    # Starts a conversation from a saved prompt. The Prompt is read only here, at
    # the controller boundary — we copy its title and never store a FK, so a
    # later edit or deletion of the template can't rewrite history. Scoping the
    # lookup through `for(@type)` honours the Prompt::SCOPES whitelist. The first
    # user Message carries the (Liquid-rendered, possibly edited) prompt text.
    #
    # We deliberately do NOT call request_reply! here: on initial creation the
    # browser hasn't subscribed to the SessionsChannel yet, so an immediate
    # generation would broadcast the streaming container before the socket is
    # listening and the reply would never render live (SEC-506 Bug 4). Instead we
    # render `show` in the reply_pending? state and let the session Stimulus
    # controller POST to RepliesController once it has connected.
    def create
      prompt = current_user.prompts.for(@type).find(params[:prompt_id])

      @session = Session.new(
        agent: Agents::Roslin.instance,
        record: @record,
        title: prompt.title,
        user: current_user
      )
      @session.messages.build(content: params[:prompt], role: :user, user: current_user)

      if @session.save
        publish_event('echo_session.created', session: { id: @session.id })
        render :show
      else
        head :unprocessable_entity
      end
    end

    private

    def record_params
      params.permit(:id, :prompt, :prompt_id, :project_id, :record, :type)
    end

    def set_record
      @record = current_project.send(@type.to_s.pluralize).find(record_params[:record])
    end

    def set_session
      @session = Session.find(record_params[:id])
      @record = scoped_record(@session)
    end

    # Whitelists the record type against Prompt::SCOPES before it reaches a
    # dynamic `current_project.send(@type.pluralize)` dispatch. An unknown type
    # is an out-of-scope request, not a 500 — raise the same RecordNotFound the
    # scoped lookups do.
    def set_type
      @type = record_params[:type]&.to_sym
      raise ActiveRecord::RecordNotFound unless Prompt::SCOPES.include?(@type)
    end
  end
end
