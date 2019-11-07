class User < ApplicationRecord
  alias_attribute :name, :email

  serialize :preferences, UserPreferences
  validates_associated :preferences

  # -- Relationships --------------------------------------------------------
  has_many :activities
  has_many :comments, dependent: :nullify
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :email,
    length: { maximum: DB_MAX_STRING_LENGTH },
    uniqueness: { allow_blank: false }

  # -- Callbacks ------------------------------------------------------------
  # -- Validations ----------------------------------------------------------
  # -- Scopes ---------------------------------------------------------------
  # Preferred notification frequencies
  scope :digests_daily, -> { where('preferences LIKE "%digest_frequency: daily%"') }
  scope :digests_instant, -> { where('preferences LIKE "%digest_frequency: instant%"') }

  # -- Class Methods --------------------------------------------------------
  # -- Instance Methods -----------------------------------------------------
end
