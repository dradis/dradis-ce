module Dradis::Plugins::Echo
  class Projects::Sessions::RepliesController < AuthenticatedController
    include ProjectScoped
    include RecordScoping
    layout false

    before_action :set_session

    # Starts generation for a freshly-created session. The session Stimulus
    # controller POSTs here from `connect`, i.e. after the browser has subscribed
    # to the SessionsChannel, so the streaming container ReplyJob broadcasts lands
    # on a listening socket (SEC-506 Bug 4). Guarded by reply_pending? so a
    # reconnect, a second viewer, or a stray POST on an already-answered session
    # can never spawn an unsolicited reply — request_reply! only fires while a
    # reply is genuinely owed.
    def create
      @session.request_reply! if @session.reply_pending?
      head :ok
    end

    private

    def set_session
      @session = Session.find(params[:session_id])
      scoped_record(@session)
    end
  end
end
