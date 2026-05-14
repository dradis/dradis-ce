module Dradis::Plugins::Echo
  class Provider::Anthropic < Provider
    validates :api_key, presence: true

    def generate(prompt:, model: nil, &block)
      raise NotImplementedError, 'Anthropic not yet implemented'
    end

    private

    def client
      # @client ||= ::Anthropic::Client.new(api_key: api_key)
    end
  end
end
