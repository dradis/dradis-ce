class AccessToken < ApplicationRecord
  serialize :token, JSON
  # Rails 7
  # encrypts :token

  # -- Relationships --------------------------------------------------------
  belongs_to :user

  # -- Callbacks ------------------------------------------------------------

  # -- Validations ----------------------------------------------------------
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :token, presence: true
  validates :user, presence: true, associated: true

  # -- Scopes -----------------------------------------------------------------

  # -- Class Methods ----------------------------------------------------------

  # -- Instance Methods -------------------------------------------------------
end
