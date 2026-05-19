module Dradis::Plugins::Echo
  class Provider::Anthropic < Provider
    include Provider::HttpStreaming

    DEFAULT_MAX_TOKENS = 4096
    ENDPOINT = 'https://api.anthropic.com/v1/messages'.freeze
    API_VERSION = '2023-06-01'.freeze

    validates :api_key, presence: true

    def generate(prompt:, model: nil, &block)
      resolved_model = model.presence || self.model
      uri = URI(ENDPOINT)

      headers = {
        'x-api-key'         => api_key,
        'anthropic-version' => API_VERSION
      }
      body = {
        model: resolved_model,
        max_tokens: DEFAULT_MAX_TOKENS,
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

    # Anthropic sends several SSE event types; only content_block_delta carries text:
    #   {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}
    # Other types (message_start, message_delta, message_stop, etc.) are skipped.
    def extract_text(parsed)
      return unless parsed['type'] == 'content_block_delta'

      parsed.dig('delta', 'text')
    end
  end
end
