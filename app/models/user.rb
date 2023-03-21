class User < ApplicationRecord
  alias_attribute :name, :email

  serialize :preferences, UserPreferences
  validates_associated :preferences

  # -- Relationships ----------------------------------------------------------
  has_many :access_tokens, dependent: :destroy
  has_many :activities
  has_many :comments, dependent: :nullify
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  # -- Callbacks --------------------------------------------------------------
  # -- Validations ------------------------------------------------------------
  validates :email,
    length: { maximum: DB_MAX_STRING_LENGTH },
    uniqueness: { allow_blank: false },
    presence: true

  # -- Scopes -----------------------------------------------------------------
  scope :enabled, -> { all }

  # -- Class Methods ----------------------------------------------------------
  # -- Instance Methods -------------------------------------------------------
end
