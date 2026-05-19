module Dradis::Plugins::Echo
  class Provider < ApplicationRecord
    self.table_name = 'dradis_plugins_echo_providers'

    ALLOWED_TYPES = []

    def self.inherited(subclass)
      super
      ALLOWED_TYPES << subclass.name.demodulize
    end

    encrypts :api_key

    validates :model, :name, presence: true

    # Sends prompt to the provider and returns the response.
    #
    # With a block: yields each text chunk as it arrives, enabling streaming UX
    # (e.g. IssueInteractionJob broadcasts each chunk to the browser via Turbo).
    #
    # Without a block: accumulates all chunks and returns the complete response
    # as a string once the API finishes, for use outside a streaming context.
    def generate(prompt:, model: nil, &block)
      raise NotImplementedError, "#{self.class.name} must implement #generate"
    end
  end
end
