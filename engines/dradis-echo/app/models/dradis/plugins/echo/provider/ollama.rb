module Dradis::Plugins::Echo
  class Provider::Ollama < Provider
    DEFAULT_ADDRESS = 'http://localhost:11434'.freeze
    DEFAULT_MODEL = 'qwen2.5:14b'.freeze

    def requires_api_key?
      false
    end

    def generate(prompt:, model: nil, &block)
      resolved_model = model.presence || self.model
      buffer = block_given? ? nil : +''

      client.generate({ model: resolved_model, prompt: prompt }) do |event, _raw|
        next if event['done']

        chunk = event['response'].to_s
        next if chunk.strip.empty?

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
