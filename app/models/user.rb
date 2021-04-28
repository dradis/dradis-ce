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
  scope :enabled, -> { all }

  # -- Class Methods --------------------------------------------------------
  def self.authenticate(email, pass)
    user = find_or_create_by(email: email)
    return user if user && BCrypt::Password.new(::Configuration.shared_password) == pass
  end

  # -- Instance Methods -----------------------------------------------------

  ActiveSupport.run_load_hooks(:user_model, self)
end
