module Dradis::Plugins::Echo
  class Prompt < ApplicationRecord
    include Defaults

    SCOPES = [ :issue ].freeze

    enum :visibility, [ :user, :team ]

    # -- Relationships ----------------------------------------------------------
    belongs_to :user

    # -- Callbacks --------------------------------------------------------------
    before_validation :set_defaults, on: :create

    # -- Validations ------------------------------------------------------------
    normalizes :scope, with: ->(type) { type.to_s }

    validates :title,
      length: { maximum: DB_MAX_STRING_LENGTH },
      presence: true,
      uniqueness: { scope: :user_id }

    validates :prompt, presence: true
    validates :scope, inclusion: SCOPES, presence: true
    validates :user, presence: true, associated: true
    validates :visibility, presence: true

    # -- Scopes -----------------------------------------------------------------
    scope :for, ->(type) { where(scope: type) }

    # -- Class Methods ----------------------------------------------------------

    # -- Instance Methods -------------------------------------------------------
    private
    def set_defaults
      self.icon ||= 'fa-star-of-life'
    end

  end
end
