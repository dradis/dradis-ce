module Node::Types
  extend ActiveSupport::Concern

  DEFAULT = 0
  HOST = 1
  METHODOLOGY = 2
  ISSUELIB = 3
  FOLDER = 4
  ATTACHMENT = 5
  UPLOAD = 6
  DESKTOP = 7
  SERVER = 8
  MOBILE = 9
  TABLET = 10
  USER = 11
  NETWORK = 12
  CREDENTIAL = 13

  LABELS = %w[
    Default
    Host
    Folder
    Attachment
    Upload
    Desktop
    Server
    Mobile
    Tablet
    User
    Network
    Credential
  ].freeze

  ICONS = [
    '',
    'fa-laptop',
    'fa-folder',
    'fa-paperclip',
    'fa-cloud-arrow-up',
    'fa-desktop',
    'fa-server',
    'fa-mobile-screen',
    'fa-tablet-screen-button',
    'fa-user',
    'fa-sitemap',
    'fa-key'
  ].freeze

  SYSTEM_TYPES = [
    METHODOLOGY,
    ISSUELIB
  ]

  included do
    # -- Callbacks ------------------------------------------------------------
    before_save do |record|
      self[:type_id] ||= DEFAULT
    end

    # -- Scopes ---------------------------------------------------------------
    scope :user_nodes, -> {
      where.not('type_id IN (?)', SYSTEM_TYPES)
    }
  end

  # -- Instance Methods -----------------------------------------------------
  def icon
    ICONS[self.type_id]
  end

  def user_node?
    !SYSTEM_TYPES.include?(self.type_id)
  end
end
