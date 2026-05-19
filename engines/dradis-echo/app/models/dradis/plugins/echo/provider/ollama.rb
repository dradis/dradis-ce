module Dradis::Plugins::Echo
  class Provider::Ollama < Provider
    ENDPOINT = '/api/chat'.freeze

    validates :address, presence: true

    def generate(prompt:, model: nil, &block)
      resolved_model = model.presence || self.model
      uri = build_uri(resolved_model)
      headers = build_headers
      body = build_body(prompt: prompt, model: resolved_model)

      buffer = block ? nil : +''

      parse_ndjson_response(uri, headers: headers, body: body) do |text|
        if block
          block.call(text)
        else
          buffer << text
        end
      end

      buffer
    end

    private

    def build_uri(_model)
      URI("#{address.chomp('/')}#{ENDPOINT}")
    end

    def build_headers
      {}
    end

    def build_body(prompt:, model:)
      {
        model: model,
        messages: [{ role: 'user', content: prompt }],
        stream: true
      }
    end

    # Ollama NDJSON envelope (/api/chat):
    #   {"message":{"role":"assistant","content":"Hello"},"done":false}
    #   {"message":{"role":"assistant","content":""},"done":true}
    # Some reasoning models (e.g. Qwen) emit <think>...</think> tags around
    # internal reasoning tokens — replace them with a readable marker.
    def extract_text(parsed)
      parsed.dig('message', 'content')
            &.sub('<think>', '{thinking}')
            &.sub('</think>', '{/thinking}')
    end

    def end_of_stream?(parsed)
      parsed['done'] == true
    end
  end
end
