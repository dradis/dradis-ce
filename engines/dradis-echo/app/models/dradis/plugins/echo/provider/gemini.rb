module Dradis::Plugins::Echo
  class Provider::Gemini < Provider
    BASE_URL = 'https://generativelanguage.googleapis.com/v1beta/models/'.freeze

    validates :api_key, presence: true

    private

    def build_uri(model)
      URI("#{BASE_URL}#{model}:streamGenerateContent?alt=sse")
    end

    def build_headers
      { 'x-goog-api-key' => api_key }
    end

    def build_body(prompt:, model:)
      {
        contents: [{ role: 'user', parts: [{ text: prompt }] }]
      }
    end

    # Gemini SSE envelope (with alt=sse query param):
    #   {"candidates":[{"content":{"parts":[{"text":"Hello"}],"role":"model"},...}]}
    # Each event is a complete GenerateContentResponse; text lives in parts[0].
    def extract_text(parsed)
      parsed.dig('candidates', 0, 'content', 'parts', 0, 'text')
    end
  end
end
