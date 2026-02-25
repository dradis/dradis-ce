module Dradis::Plugins::Echo
  class Prompt < ApplicationRecord
    include Defaults

    PROMPT_TYPES = [ :issue ].freeze

    enum :visibility, [ :personal, :shared ]

    # -- Relationships ----------------------------------------------------------
    belongs_to :user

    # -- Callbacks --------------------------------------------------------------
    # -- Validations ------------------------------------------------------------
    # -- Scopes -----------------------------------------------------------------
    # -- Class Methods ----------------------------------------------------------
  end
end
