class User < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  has_many :activities
  has_many :comments, dependent: :nullify
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :email,
    format: { with: /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i },
    length: { maximum: 255 },
    uniqueness: { allow_blank: false }

  # -- Callbacks ------------------------------------------------------------
  # -- Validations ----------------------------------------------------------
  # -- Scopes ---------------------------------------------------------------
  # -- Class Methods --------------------------------------------------------
  # -- Instance Methods -----------------------------------------------------
end
