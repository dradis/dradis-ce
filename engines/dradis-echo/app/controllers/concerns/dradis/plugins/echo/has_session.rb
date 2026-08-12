module Dradis::Plugins::Echo
  # Loads the URL-nested session for the message/reply controllers and re-scopes
  # it through the current project, so an out-of-scope session_id raises
  # ActiveRecord::RecordNotFound rather than leaking another project's session.
  # Pulls in RecordScoping for the scoped lookup; consumers only include this.
  module HasSession
    extend ActiveSupport::Concern
    include RecordScoping

    included do
      before_action :set_session
    end

    private

    def set_session
      @session = Session.find(params[:session_id])
      scoped_record(@session)
    end
  end
end
