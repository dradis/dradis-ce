require 'net/http'
require 'json'
require 'uri'

module Dradis::Plugins::Echo
  module Provider::HttpStreaming
    READ_TIMEOUT = 120

    private

    # Makes a POST request and parses the SSE response line by line, calling
    # the block with each extracted text chunk. Subclasses must implement
    # #extract_text to pull the text string out of each provider's specific JSON
    # envelope — the structure varies across APIs.
    def parse_sse_response(uri, headers:, body:, &block)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.read_timeout = READ_TIMEOUT

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      headers.each { |k, v| request[k] = v }
      request.body = JSON.generate(body)

      buffer = +''

      http.request(request) do |response|
        raise "#{self.class.name} API error (#{response.code}): #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        response.read_body do |chunk|
          buffer << chunk
          while (line_end = buffer.index("\n"))
            line = buffer.slice!(0, line_end + 1).strip
            next unless line.start_with?('data:')

            data = line.sub(/\Adata:\s*/, '')
            next if end_of_stream_marker && data == end_of_stream_marker

            parsed = JSON.parse(data) rescue next
            text = extract_text(parsed)
            block.call(text) if text.present? && block
          end
        end
      end
    end

    # Extracts the text chunk from a parsed SSE event object.
    # Each provider wraps the text differently — implement this in the subclass.
    def extract_text(_parsed)
      raise NotImplementedError, "#{self.class.name} must implement #extract_text"
    end

    # Returns the end-of-stream marker string for this provider, or nil if the
    # provider ends the connection without one (Anthropic, Gemini). Override in
    # subclasses that use one.
    def end_of_stream_marker
      nil
    end
  end
end
