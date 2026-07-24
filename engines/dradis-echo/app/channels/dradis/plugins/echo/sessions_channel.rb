module Dradis::Plugins::Echo
  # Custom Turbo Streams channel for Echo sessions. Turbo's default channel
  # trusts any client holding a validly-signed stream name for the lifetime of
  # that name — which never expires — so a user who loses project access could
  # subscribe and keep receiving the transcript. We re-check authorization when
  # a subscription is established: resolve the session behind the signed name
  # and only stream if the subscriber may still :use its project, otherwise
  # reject. Note this guards *new* subscriptions only; a connection opened while
  # still authorized keeps streaming until it is torn down.
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
    # yields nil (never reaching locate), so the only raise path left is a
    # session deleted between signing and subscribe — RecordNotFound, which we
    # treat as unauthorized. Narrower than a blanket rescue so genuine bugs
    # (NoMethodError etc.) still surface.
    def session_from_stream_name
      name = verified_stream_name_from_params
      return unless name

      record = GlobalID::Locator.locate(name.split(':').first)
      record if record.is_a?(Session)
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end
