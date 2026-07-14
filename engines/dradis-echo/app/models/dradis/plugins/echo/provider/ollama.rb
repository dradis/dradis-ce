module Dradis::Plugins::Echo
  class Provider::Ollama < Provider
    DEFAULT_ADDRESS = 'http://localhost:11434'.freeze
    DEFAULT_MODEL = 'qwen2.5:14b'.freeze

    def requires_api_key?
      false
    end

    def generate(messages: nil, prompt: nil, model: nil, &block)
      resolved_model = model.presence || self.model
      resolved_messages = resolve_messages(messages, prompt)
      buffer = block_given? ? nil : +''

      client.chat({ model: resolved_model, messages: resolved_messages }) do |event, _raw|
        next if event['done']

        chunk = event.dig('message', 'content').to_s
        next if chunk.empty?

        chunk = chunk.sub('<think>', '{thinking}').sub('</think>', '{/thinking}')

        if block_given?
          yield chunk
        else
          buffer << chunk
        end
      end

      buffer
    end

    private

    def client
      @client ||= ::Ollama.new(
        credentials: { address: address },
        options: { server_sent_events: true }
      )
    end
  end
end
