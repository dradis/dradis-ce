module Node::Types
  extend ActiveSupport::Concern

  DEFAULT = 0
  HOST = 1
  METHODOLOGY = 2
  ISSUELIB = 3
  CONTENTLIB = 4
  FOLDER = 5
  ATTACHMENT = 6
  UPLOAD = 7
  DESKTOP = 8
  SERVER = 9
  MOBILE = 10
  TABLET = 11
  USER = 12
  NETWORK = 13
  CREDENTIAL = 14
  DATABASE = 15

  LABELS = %w[
    Default
    Host
    Methodology
    IssueLib
    ContentLib
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
    Database
  ].freeze

  ICONS = [
    '',
    'fa-laptop',
    '',
    '',
    '',
    'fa-folder',
    'fa-paperclip',
    'fa-cloud',
    'fa-desktop',
    'fa-server',
    'fa-mobile-screen',
    'fa-tablet-screen-button',
    'fa-user',
    'fa-sitemap',
    'fa-key',
    'fa-database'
  ].freeze

  SYSTEM_TYPES = [
    METHODOLOGY,
    ISSUELIB,
    CONTENTLIB
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
