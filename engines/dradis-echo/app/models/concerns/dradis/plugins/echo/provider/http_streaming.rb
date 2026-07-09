require 'net/http'
require 'json'
require 'uri'

module Dradis::Plugins::Echo
  module Provider::HttpStreaming
    extend ActiveSupport::Concern

    READ_TIMEOUT = 120

    # Sends prompt to the provider and returns the response.
    #
    # With a block: yields each text chunk as it arrives, enabling streaming UX
    # (e.g. InteractionJob broadcasts each chunk to the browser via Turbo).
    #
    # Without a block: accumulates all chunks and returns the complete response
    # as a string once the API finishes, for use outside a streaming context.
    #
    # Subclasses must implement: #build_uri, #build_headers, #build_body,
    # #extract_text. Optionally override #end_of_stream_marker.
    def generate(prompt:, model: nil, &block)
      resolved_model = model.presence || self.model
      uri = build_uri(resolved_model)
      headers = build_headers
      body = build_body(prompt: prompt, model: resolved_model)

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

    # Makes a POST request and parses the SSE response line by line, calling
    # the block with each extracted text chunk. Subclasses must implement
    # #extract_text to pull the text string out of each provider's specific JSON
    # envelope — the structure varies across APIs.
    def parse_sse_response(uri, headers:, body:, &block)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = 10
      http.read_timeout = READ_TIMEOUT
      http.write_timeout = 10

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      headers.each { |k, v| request[k] = v }
      request.body = JSON.generate(body)

      buffer = +''

      http.request(request) do |response|
        unless response.is_a?(Net::HTTPSuccess)
          error_body = +''
          response.read_body { |chunk| error_body << chunk }
          raise "#{self.class.name} API error (#{response.code}): #{error_body}"
        end

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

    # Returns the URI for the provider's API endpoint.
    # Receives the resolved model name (provider default or caller override).
    def build_uri(_model)
      raise NotImplementedError, "#{self.class.name} must implement #build_uri"
    end

    # Returns a hash of HTTP headers for authentication and API versioning.
    def build_headers
      raise NotImplementedError, "#{self.class.name} must implement #build_headers"
    end

    # Returns the request body hash for the provider's API.
    def build_body(prompt:, model:)
      raise NotImplementedError, "#{self.class.name} must implement #build_body"
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
