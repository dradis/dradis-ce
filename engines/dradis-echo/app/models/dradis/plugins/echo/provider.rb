module Dradis::Plugins::Echo
  class Provider < ApplicationRecord
    include Provider::HttpStreaming

    self.table_name = 'dradis_plugins_echo_providers'

    # Each subclass automatically adds itself when loaded, so
    # the list remains up-to-date when we add new providers.
    ALLOWED_TYPES = []

    def self.inherited(subclass)
      super
      ALLOWED_TYPES << subclass.name.demodulize
    end

    encrypts :api_key

    validates :model, :name, presence: true

    def type_name
      self.class.name.demodulize
    end

    def partial_name
      self.class.name.demodulize.underscore
    end

    # When more agents exist, replace this with a registry pattern:
    # each element registers itself via Provider.register_element(self)
    # and in_use? iterates over them instead of hardcoding.
    def in_use?
      Roslin::IssueInteraction.settings.provider_id.to_s == id.to_s
    end
  end
end

require_relative 'provider/anthropic'
require_relative 'provider/ollama'
require_relative 'provider/open_ai'
