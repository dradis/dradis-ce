class Subscription < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  belongs_to :subscribable, polymorphic: true
  belongs_to :user

  # -- Callbacks ------------------------------------------------------------

  # -- Validations ----------------------------------------------------------
  validates :subscribable, presence: true, associated: true
  validates :user, presence: true, associated: true

  # -- Scopes ---------------------------------------------------------------

  # -- Class Methods --------------------------------------------------------

  # -- Instance Methods -----------------------------------------------------
end
