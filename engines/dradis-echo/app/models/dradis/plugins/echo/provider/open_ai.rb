module Dradis::Plugins::Echo
  class Provider::OpenAI < Provider
    DEFAULT_ADDRESS = 'https://api.openai.com/v1/'.freeze

    before_validation :set_default_address

    validates :address, :api_key, presence: true

    def generate(prompt:, model: nil, &block)
      raise NotImplementedError, 'OpenAI not yet implemented'
    end

    private

    def set_default_address
      self.address = DEFAULT_ADDRESS if address.blank?
    end

    def client
      #@client ||= ::OpenAI::Client.new(access_token: api_key, uri_base: address)
    end
  end
end
