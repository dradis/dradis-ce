class User < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  has_many :activities
  has_many :comments, dependent: :nullify
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  # -- Callbacks ------------------------------------------------------------
  # -- Validations ----------------------------------------------------------
  # -- Scopes ---------------------------------------------------------------
  # -- Class Methods --------------------------------------------------------
  # -- Instance Methods -----------------------------------------------------
end
