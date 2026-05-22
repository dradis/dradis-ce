module Dradis::Plugins::Echo
  class Provider < ApplicationRecord
    # Each subclass automatically adds itself when loaded, so
    # the list remains up-to-date when we add new providers.
    ALLOWED_TYPES = []

    def self.inherited(subclass)
      super
      ALLOWED_TYPES << subclass.name.demodulize
    end

    has_many :agents, dependent: :restrict_with_error

    encrypts :api_key

    normalizes :address, with: ->(a) { a.strip.chomp('/') }

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

    def generate(prompt:, model: nil, &block)
      raise NotImplementedError, "#{self.class.name} must implement #generate"
    end

    def icon_name
      self.class.name.demodulize.underscore
    end

    def requires_api_key?
      true
    end

    def type_name
      self.class.name.demodulize
    end
  end
end
