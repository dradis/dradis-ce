module Dradis::Plugins::Echo
  class Provider::OpenAI < Provider
    DEFAULT_ADDRESS = 'https://api.openai.com/v1/'.freeze
    END_OF_STREAM_MARKER = '[DONE]'.freeze

    validates :api_key, presence: true

    private

    def build_uri(_model)
      base = address.presence || DEFAULT_ADDRESS
      URI.join(base, 'chat/completions')
    end

    def build_headers
      { 'Authorization' => "Bearer #{api_key}" }
    end

    def build_body(prompt:, model:)
      {
        model: model,
        messages: [{ role: 'user', content: prompt }],
        stream: true
      }
    end

    def end_of_stream_marker
      END_OF_STREAM_MARKER
    end

    # OpenAI SSE envelope:
    #   {"choices":[{"delta":{"content":"Hello"},"finish_reason":null}],...}
    # Non-content deltas (role, finish) have no "content" key — dig returns nil.
    def extract_text(parsed)
      parsed.dig('choices', 0, 'delta', 'content')
    end
  end
end
