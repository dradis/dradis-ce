module Dradis::Plugins::Echo
  class Provider < ApplicationRecord
    include Provider::HttpStreaming

    self.table_name = 'dradis_plugins_echo_providers'

    ALLOWED_TYPES = []

    def self.inherited(subclass)
      super
      ALLOWED_TYPES << subclass.name.demodulize
    end

    encrypts :api_key

    validates :model, :name, presence: true
  end
end
