module Dradis::Plugins::Echo
  class Provider::OpenAI < Provider
    include Provider::HttpStreaming

    DEFAULT_ADDRESS = 'https://api.openai.com/v1'.freeze
    DEFAULT_MODEL = 'gpt-4o'.freeze
    END_OF_STREAM_MARKER = '[DONE]'.freeze

    private

    def build_body(prompt:, model:)
      {
        model: model,
        messages: [{ role: 'user', content: prompt }],
        stream: true
      }
    end

    def build_headers
      { 'Authorization' => "Bearer #{api_key}" }
    end

    def build_uri(_model)
      URI("#{address}/chat/completions")
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
