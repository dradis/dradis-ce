module Dradis::Plugins::Echo
  class ReplyJob < ApplicationJob
    queue_as :dradis_project

    # How often, at most, to touch the streaming message so Session's stuck-
    # generation reclaim can tell a live-but-slow stream from a dead one without
    # a database write per chunk.
    TOUCH_INTERVAL = 5

    # Generates one assistant reply for a session: it streams the provider
    # response into a `streaming` message, persists the final text as
    # `complete` with model/provider metadata, then serializes — re-enqueueing
    # itself if the user spoke again mid-generation, or flipping the session
    # back to `idle`. Session#request_reply! owns the idle->generating gate.
    def perform(session)
      agent = session.agent
      raise "Agent '#{agent.name}' is not enabled" unless agent.enabled?

      cutoff_id = session.messages.maximum(:id).to_i
      context = session.to_provider_messages
      message = session.messages.create!(role: :assistant, status: :streaming)

      text, duration_ms = stream_reply(agent, session, message, context)

      complete(agent, message, text, duration_ms)
      serialize(session, cutoff_id)
    rescue Provider::HttpStreaming::Error => e
      # A genuine provider/transport failure: surface it to the user as a failed
      # message. Anything else (a disabled agent, a bug in our code) is left to
      # propagate so it reaches Resque's failed queue instead of being hidden.
      fail_message(session, message, e)
    end

    private

    def stream_reply(agent, session, message, context)
      buffer = +''
      started = clock
      last_touch = started

      agent.provider.generate(messages: context, model: agent.model_override.presence) do |chunk|
        buffer << chunk
        broadcast_chunk(session, message, chunk)

        # Throttled liveness signal for Session#reclaim_stuck_generation!.
        if clock - last_touch >= TOUCH_INTERVAL
          message.touch
          last_touch = clock
        end
      end

      [buffer, ((clock - started) * 1000).round]
    end

    def broadcast_chunk(session, message, chunk)
      Turbo::StreamsChannel.broadcast_append_to(
        [session, :messages],
        target: [message, :content],
        content: ERB::Util.html_escape(chunk)
      )
    end

    def complete(agent, message, text, duration_ms)
      message.update!(
        content: strip_thinking(text),
        status: :complete,
        metadata: message.metadata.merge(
          'duration_ms' => duration_ms,
          'model' => agent.model_override.presence || agent.provider.model,
          'provider' => agent.provider.type_name
        )
      )
      broadcast_message(message)
    end

    # Providers surface their reasoning either as raw <think></think> tags or,
    # for Ollama, as the {thinking}{/thinking} markers Provider::Ollama swaps
    # them for. Neither belongs in the persisted answer, so drop the blocks
    # and any stray markers before saving.
    def strip_thinking(text)
      text
        .gsub(/\{thinking\}.*?\{\/thinking\}/m, '')
        .gsub(/<think>.*?<\/think>/m, '')
        .gsub(/\{\/?thinking\}/, '')
        .gsub(/<\/?think>/, '')
        .strip
    end

    # Under a lock so it can't race the controller flipping idle<->generating:
    # if a user message landed after the reply started (id past the cutoff),
    # answer it too by re-enqueueing; otherwise release the session to idle.
    def serialize(session, cutoff_id)
      session.with_lock do
        if session.messages.where(role: :user).where('id > ?', cutoff_id).exists?
          self.class.perform_later(session)
        else
          session.update!(status: :idle)
          session.broadcast_composer_state
        end
      end
    end

    def fail_message(session, message, error)
      Rails.logger.error(
        "#{self.class.name} failed: #{error.class}: #{error.message}\n" \
        "#{Array(error.backtrace).join("\n")}"
      )

      if message
        message.update!(
          status: :failed,
          metadata: message.metadata.merge('error' => Message::GENERIC_ERROR)
        )
        broadcast_message(message)
      end

      session.with_lock { session.update!(status: :idle) }
      session.broadcast_composer_state
    end

    def broadcast_message(message)
      message.broadcast_replace_to(
        [message.session, :messages],
        partial: 'dradis/plugins/echo/projects/sessions/messages/message',
        locals: { message: message }
      )
    end

    def clock
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
