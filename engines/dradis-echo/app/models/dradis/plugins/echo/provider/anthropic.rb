module Dradis::Plugins::Echo
  class Provider::Anthropic < Provider
    include Provider::HttpStreaming

    API_VERSION = '2023-06-01'.freeze
    DEFAULT_ADDRESS = 'https://api.anthropic.com/v1/messages'.freeze
    DEFAULT_MAX_TOKENS = 4096
    DEFAULT_MODEL = 'claude-sonnet-4-6'.freeze

    private

    def build_body(prompt:, model:)
      {
        max_tokens: DEFAULT_MAX_TOKENS,
        messages: [{ role: 'user', content: prompt }],
        model: model,
        stream: true
      }
    end

    def build_headers
      {
        'anthropic-version' => API_VERSION,
        'x-api-key'         => api_key
      }
    end

    def build_uri(_model)
      URI(address)
    end

    # Anthropic sends several SSE event types; only content_block_delta carries text:
    #   {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}
    # Other types (message_start, message_delta, message_stop, etc.) are skipped.
    def extract_text(parsed)
      return unless parsed['type'] == 'content_block_delta'

      parsed.dig('delta', 'text')
    end
  end
end
