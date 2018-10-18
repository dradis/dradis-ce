class Subscription < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  belongs_to :subscribable, polymorphic: true, touch: true
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
    false
  end

  # -- Instance Methods -----------------------------------------------------
  # Because Issue descends from Note but doesn't use STI, Rails's default
  # polymorphic setter will set 'subscribable_type' to 'Note' when you pass an
  # Issue to subscribable. This means when you load the Subscription later then
  # subscribable will return the wrong class. Override the default behaviour here
  # for issues:
  #
  # FIXME - ISSUE/NOTE INHERITANCE
  def subscribable=(new_subscribable)
    super
    self.subscribable_type = 'Issue' if new_subscribable.is_a?(Issue)
    new_subscribable
  end
end
