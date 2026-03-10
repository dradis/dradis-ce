module Prompt::Icons
  extend ActiveSupport::Concern

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

  included do
    # -- Validations ------------------------------------------------------------
    validates :icon, inclusion: ICONS, presence: true
  end
end
