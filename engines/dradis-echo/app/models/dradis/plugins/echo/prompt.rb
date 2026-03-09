module Dradis::Plugins::Echo
  class Prompt < ApplicationRecord
    include Defaults

    SCOPES = [ :issue ].freeze

    LABELS = [
      'AI Generation',
      'Alert',
      'Analysis',
      'Automation',
      'Code Review',
      'Command Line',
      'Credentials',
      'Database',
      'Encryption',
      'Forensics',
      'General',
      'Infrastructure',
      'Investigation',
      'Network',
      'Reconnaissance',
      'Report',
      'Reword',
      'Risk Scoring',
      'Scope',
      'Secure Document',
      'Security',
      'Summary',
      'Vulnerabilities',
      'Web Application',
      'Writing Style'
    ].freeze

    ICONS = %w[
      fa-wand-magic-sparkles
      fa-circle-exclamation
      fa-brain
      fa-robot
      fa-code
      fa-terminal
      fa-key
      fa-database
      fa-lock
      fa-fingerprint
      fa-star-of-life
      fa-server
      fa-magnifying-glass
      fa-network-wired
      fa-user-secret
      fa-file-lines
      fa-shuffle
      fa-gauge
      fa-bullseye
      fa-file-shield
      fa-shield-halved
      fa-clipboard-list
      fa-bug
      fa-globe
      fa-feather-pointed
    ].freeze

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
      uniqueness: { scope: :user_id }

    validates :icon, inclusion: ICONS, presence: true
    validates :prompt, presence: true
    validates :scope, inclusion: SCOPES.map(&:to_s), presence: true
    validates :user, presence: true, associated: true
    validates :visibility, presence: true

    # -- Scopes -----------------------------------------------------------------
    scope :for, ->(value) { where(scope: value) }

    # -- Class Methods ----------------------------------------------------------

    # -- Instance Methods -------------------------------------------------------
    private
    def set_defaults
      self.icon ||= 'fa-star-of-life'
    end
  end
end
