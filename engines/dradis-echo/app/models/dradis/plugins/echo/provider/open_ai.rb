module Dradis::Plugins::Echo
  class Provider::OpenAI < Provider
    include Provider::HttpStreaming

    DEFAULT_ADDRESS = 'https://api.openai.com/v1/'.freeze
    END_OF_STREAM_MARKER = '[DONE]'.freeze

    validates :api_key, presence: true

    def generate(prompt:, model: nil, &block)
      resolved_model = model.presence || self.model
      base = address.presence || DEFAULT_ADDRESS
      uri = URI.join(base, 'chat/completions')

      headers = { 'Authorization' => "Bearer #{api_key}" }
      body = {
        model: resolved_model,
        messages: [{ role: 'user', content: prompt }],
        stream: true
      }

      buffer = block ? nil : +''

      parse_sse_response(uri, headers: headers, body: body) do |text|
        if block
          block.call(text)
        else
          buffer << text
        end
      end

      buffer
    end

    private

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
