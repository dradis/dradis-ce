module Dradis::Plugins::Echo
  class Provider < ApplicationRecord
    include EncryptedColumn

    self.table_name = 'dradis_plugins_echo_providers'

    ALLOWED_TYPES = []

    def self.inherited(subclass)
      super
      ALLOWED_TYPES << subclass.name.demodulize
    end

    encrypted_column :api_key

    validates :model, :name, presence: true

    def generate(prompt:, model: nil, &block)
      raise NotImplementedError, "#{self.class.name} must implement #generate"
    end
  end
end

require_relative 'provider/anthropic'
require_relative 'provider/ollama'
require_relative 'provider/open_ai'
