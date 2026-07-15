module Dradis::Plugins::Echo
  # Custom Turbo Streams channel for Echo sessions. Turbo's default channel
  # trusts any client holding a validly-signed stream name for the lifetime of
  # that name — which never expires — so a user who loses project access keeps
  # receiving the transcript. We re-check authorization at subscribe time
  # instead: resolve the session behind the signed name and only stream if the
  # subscriber may still :use its project, otherwise reject.
  #
  # Follows the documented turbo-rails custom-channel pattern
  # (Turbo::StreamsChannel).
  class SessionsChannel < ApplicationCable::Channel
    extend Turbo::Streams::Broadcasts, Turbo::Streams::StreamName
    include Turbo::Streams::StreamName::ClassMethods

    def subscribed
      session = session_from_stream_name

      if session && authorized?(session)
        stream_from verified_stream_name_from_params
      else
        reject
      end
    end

    private

    def authorized?(session)
      Ability.new(current_user).can?(:use, session.record.project)
    end

    # The signed name encodes `[session, :messages]`, i.e.
    # "<session-gid-param>:messages". A tampered name fails verification and
    # yields nil, which we treat as unauthorized.
    def session_from_stream_name
      name = verified_stream_name_from_params
      return unless name

      record = GlobalID::Locator.locate(name.split(':').first)
      record if record.is_a?(Session)
    rescue StandardError
      nil
    end
  end
end
