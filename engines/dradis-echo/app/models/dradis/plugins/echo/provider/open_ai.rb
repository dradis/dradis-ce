module Dradis::Plugins::Echo
  class Provider::OpenAI < Provider
    validates :address, :api_key, presence: true

    def generate(prompt:, model: nil, &block)
      raise NotImplementedError, 'OpenAI not yet implemented'
    end

    private

    def client
      #@client ||= ::OpenAI::Client.new(access_token: api_key, uri_base: address)
    end
  end
end
