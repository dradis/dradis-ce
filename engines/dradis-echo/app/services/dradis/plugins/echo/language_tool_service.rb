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
      response = post_check(field_name, text)

      unless response.is_a?(Net::HTTPSuccess)
        message = rejection_message(response)
        Rails.logger.error "LanguageTool rejected the request (field: #{field_name}): #{message}"
        raise RejectedError, message
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
    rescue JSON::ParserError => e
      Rails.logger.error "LanguageTool returned invalid JSON (field: #{field_name}): #{e.message}"
      raise UnavailableError, 'LanguageTool returned an unexpected response.'
    end

    def post_check(field_name, text)
      uri = URI("#{@address}/v2/check")
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', open_timeout: 5, read_timeout: 10) do |http|
        http.post(uri.path, URI.encode_www_form(text: text, language: @language))
      end
    rescue StandardError => e
      Rails.logger.error "LanguageTool unavailable (field: #{field_name}): #{e.message}"
      raise UnavailableError, 'Could not reach LanguageTool. Is the container running?'
    end

    # LanguageTool explains rejected requests (e.g. an unknown language code) in
    # a plain-text body. Surface it so users can fix their configuration.
    def rejection_message(response)
      detail = response.body.to_s.strip.truncate(300).presence || "HTTP #{response.code}"
      "LanguageTool rejected the request: #{detail}"
    end
  end
end
