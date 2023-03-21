class AccessToken < ApplicationRecord
  include EncryptedColumn

  # FIXME: Rails 7 can take care of serialization, for now we do this manually
  # serialize :token, JSON

  # FIXME: Rails 7
  # encrypts :token
  encrypted_column :token

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
