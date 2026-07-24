module Dradis::Plugins::Echo
  class Projects::Sessions::MessagesController < AuthenticatedController
    include ProjectScoped
    include RecordScoping
    layout false

    before_action :set_session

    # Appends a user turn and re-opens the reply gate. The new message
    # broadcasts itself into the transcript, so there's nothing to render back.
    def create
      message = @session.messages.build(content: params[:content], role: :user, user: current_user)

      if message.save
        @session.request_reply!
        head :ok
      else
        head :unprocessable_entity
      end
    end

    private

    def set_session
      @session = Session.find(params[:session_id])
      scoped_record(@session)
    end
  end
end
