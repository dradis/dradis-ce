module Dradis::Plugins::Echo
  class Provider < ApplicationRecord
    self.table_name = 'dradis_plugins_echo_providers'

    # Each subclass automatically adds itself when loaded, so
    # the list remains up-to-date when we add new providers.
    ALLOWED_TYPES = []

    def self.inherited(subclass)
      super
      ALLOWED_TYPES << subclass.name.demodulize
    end

    encrypts :api_key

    validates :address, presence: true,
                        format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                                  message: 'must be a valid HTTP(S) URL' }
    validates :api_key, presence: true, if: :requires_api_key?
    validates :model, :name, presence: true

    def self.default_address
      self::DEFAULT_ADDRESS
    end

    def self.default_model
      self::DEFAULT_MODEL
    end

    def icon_name
      self.class.name.demodulize.underscore
    end

    # When more agents exist, replace this with a registry pattern:
    # each element registers itself via Provider.register_element(self)
    # and in_use? iterates over them instead of hardcoding.
    def in_use?
      Roslin::IssueInteraction.settings.provider_id.to_s == id.to_s
    end

    def requires_api_key?
      true
    end

    def type_name
      self.class.name.demodulize
    end
  end
end
