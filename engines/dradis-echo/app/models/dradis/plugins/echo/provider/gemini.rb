module Dradis::Plugins::Echo
  class Provider::Gemini < Provider
    include Provider::HttpStreaming

    BASE_URL = 'https://generativelanguage.googleapis.com/v1beta/models/'.freeze

    validates :api_key, presence: true

    def generate(prompt:, model: nil, &block)
      resolved_model = model.presence || self.model
      uri = URI("#{BASE_URL}#{resolved_model}:streamGenerateContent?alt=sse")

      headers = { 'x-goog-api-key' => api_key }
      body = {
        contents: [{ role: 'user', parts: [{ text: prompt }] }]
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

    # Gemini SSE envelope (with alt=sse query param):
    #   {"candidates":[{"content":{"parts":[{"text":"Hello"}],"role":"model"},...}]}
    # Each event is a complete GenerateContentResponse; text lives in parts[0].
    def extract_text(parsed)
      parsed.dig('candidates', 0, 'content', 'parts', 0, 'text')
    end
  end
end
