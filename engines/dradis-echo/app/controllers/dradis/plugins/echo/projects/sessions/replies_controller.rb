module Dradis::Plugins::Echo
  class Projects::Sessions::RepliesController < AuthenticatedController
    include HasSession
    include ProjectScoped
    layout false

    # Starts generation for a freshly-created session. The session Stimulus
    # controller POSTs here from `connect`, i.e. after the browser has subscribed
    # to the SessionsChannel, so the streaming container ReplyJob broadcasts lands
    # on a listening socket. Guarded by reply_pending? so a
    # reconnect, a second viewer, or a stray POST on an already-answered session
    # can never spawn an unsolicited reply — request_reply! only fires while a
    # reply is genuinely owed.
    def create
      @session.request_reply! if @session.reply_pending?
      head :ok
    end
  end
end
