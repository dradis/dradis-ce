module Dradis::Plugins::Echo
  class Provider::Gemini < Provider
    include Provider::HttpStreaming

    DEFAULT_ADDRESS = 'https://generativelanguage.googleapis.com/v1beta/models'.freeze
    DEFAULT_MODEL = 'gemini-2.5-flash'.freeze
    ROLE_MAP = { 'assistant' => 'model' }.freeze

    private

    # Gemini names the assistant role "model" and wraps content in a parts
    # array, so map each message into its contents structure.
    def build_body(messages:, model:)
      {
        contents: messages.map { |message|
          { role: ROLE_MAP.fetch(message[:role], message[:role]),
            parts: [{ text: message[:content] }] }
        }
      }
    end

    def build_headers
      { 'x-goog-api-key' => api_key }
    end

    def build_uri(model)
      URI("#{address}/#{model}:streamGenerateContent?alt=sse")
    end

    # Gemini SSE envelope (with alt=sse query param):
    #   {"candidates":[{"content":{"parts":[{"text":"Hello"}],"role":"model"},...}]}
    # Each event is a complete GenerateContentResponse; text lives in parts[0].
    def extract_text(parsed)
      parsed.dig('candidates', 0, 'content', 'parts', 0, 'text')
    end
  end
end
