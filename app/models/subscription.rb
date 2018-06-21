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
  def self.subscribe(user:, to:)
    self.create!(
      user: user,
      subscribable: to
    )
  rescue ActiveRecord::RecordNotUnique
    # Don't worry about dupes
  end

  # -- Instance Methods -----------------------------------------------------
end
