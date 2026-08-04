module Dradis::Plugins::Echo
  class Projects::Sessions::MessagesController < AuthenticatedController
    include HasSession
    include ProjectScoped
    layout false

    # Appends a user turn and re-opens the reply gate. The new message
    # broadcasts itself into the transcript, so there's nothing to render back.
    def create
      message = @session.messages.build(content: params.expect(:content), user: current_user)

      if message.save
        @session.request_reply!
        head :ok
      else
        head :unprocessable_entity
      end
    end
  end
end
