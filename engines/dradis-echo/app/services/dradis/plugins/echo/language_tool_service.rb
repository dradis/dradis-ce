module Dradis::Plugins::Echo
  class LanguageToolService
    class UnavailableError < StandardError; end

    def initialize(fields:, address:)
      @fields  = fields
      @address = address
    end

    def call
      @fields.flat_map { |field_name, text| check_field(field_name, text) }
    end

    private

    def check_field(field_name, text)
      uri      = URI("#{@address}/v2/check")
      response = Net::HTTP.start(uri.host, uri.port, open_timeout: 5, read_timeout: 10) do |http|
        http.post(uri.path, URI.encode_www_form(text: text, language: 'en-US'))
      end

      JSON.parse(response.body)['matches'].map do |m|
        {
          field_name:   field_name,
          offset:       m['offset'],
          length:       m['length'],
          message:      m['message'],
          exact:        text[m['offset'], m['length']],
          replacements: m['replacements'].map { |r| r['value'] }.first(3)
        }
      end
    rescue StandardError => e
      Rails.logger.error "LanguageTool unavailable (field: #{field_name}): #{e.message}"
      raise UnavailableError, 'Could not reach LanguageTool. Is the container running?'
    end
  end
end
