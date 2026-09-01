module Dradis::Plugins::Echo
  class Prompt < ApplicationRecord
    include Defaults
    include Icons

    SCOPES = [ :issue ].freeze

    enum :visibility, [ :user, :team ]

    # -- Relationships ----------------------------------------------------------
    belongs_to :user

    # -- Callbacks --------------------------------------------------------------
    before_validation :set_defaults, on: :create

    # -- Validations ------------------------------------------------------------
    normalizes :scope, with: ->(value) { value.to_s }

    validates :title,
      length: { maximum: DB_MAX_STRING_LENGTH },
      presence: true,
      uniqueness: { scope: [ :user_id, :scope ] }

    validates :prompt, presence: true
    validates :scope, inclusion: SCOPES.map(&:to_s), presence: true
    validates :user, presence: true, associated: true
    validates :visibility, presence: true

    # -- Scopes -----------------------------------------------------------------
    scope :for, ->(value) { where(scope: value) }

    # -- Class Methods ----------------------------------------------------------

    # Checks emptiness per scope, not globally, so a user with prompts in
    # one scope still gets another scope's defaults backfilled.
    def self.ensure_defaults_for!(user, scope)
      prompts = user.prompts.for(scope).to_a
      return prompts unless prompts.empty?

      user.prompts << defaults_for(scope)
      user.prompts.for(scope).to_a
    end

    # -- Instance Methods -------------------------------------------------------
    private
    def set_defaults
      self.icon ||= 'fa-star-of-life'
    end
  end
end
