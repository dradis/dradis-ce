module Dradis::Plugins::Echo
  class Projects::Sessions::RepliesController < AuthenticatedController
    include HasSession
    include ProjectScoped
    layout false

    # Starts generation for a freshly-created session. The session Stimulus
    # controller POSTs here from `connect` — after subscribing to the
    # SessionsChannel — so ReplyJob's streaming container lands on a listening
    # socket. reply_pending? guards against a reconnect or stray POST spawning an
    # unsolicited reply on an already-answered session.
    def create
      @session.request_reply! if @session.reply_pending?
      head :ok
    end
  end
end
