module Dradis::Plugins::Echo
  class LanguageToolService
    class Error < StandardError; end
    class RejectedError < Error; end
    class UnavailableError < Error; end

    DEFAULT_ADDRESS = 'http://localhost:8081'.freeze
    DEFAULT_LANGUAGE = 'en-US'.freeze

    def self.reachable?(address)
      uri = URI("#{address.strip.chomp('/')}/v2/languages")
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', open_timeout: 2, read_timeout: 2) do |http|
        http.head(uri.path)
      end
      true
    rescue StandardError
      false
    end

    def initialize(address:, fields:, language:)
      @address = address.strip.chomp('/')
      @fields = fields
      @language = language
    end

    def call
      @fields.flat_map { |field_name, text| check_field(field_name, text) }
    end

    private

    def check_field(field_name, text)
      uri = URI("#{@address}/v2/check")
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', open_timeout: 5, read_timeout: 10) do |http|
        http.post(uri.path, URI.encode_www_form(text: text, language: @language))
      end

      # LanguageTool explains rejected requests (e.g. an unknown language code) in
      # a plain-text body that can list every supported language code. Surface the
      # start of it so users can fix their configuration.
      unless response.is_a?(Net::HTTPSuccess)
        detail = response.body.to_s.strip.truncate(120, separator: ' ').presence || "HTTP #{response.code}"
        raise RejectedError, "LanguageTool error: #{detail}"
      end

      JSON.parse(response.body).fetch('matches', []).map do |m|
        {
          field_name: field_name,
          offset: m['offset'],
          length: m['length'],
          message: m['message'],
          exact: text[m['offset'], m['length']],
          replacements: m['replacements'].map { |r| r['value'] }.first(3)
        }
      end
    rescue *Provider::HttpStreaming::NETWORK_ERRORS, JSON::ParserError => e
      Rails.logger.error "LanguageTool unavailable (field: #{field_name}): #{e.message}"
      raise UnavailableError, 'Could not reach LanguageTool. Is the container running?'
    end
  end
end
