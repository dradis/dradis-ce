class Activity < ApplicationRecord

  # -- Relationships --------------------------------------------------------

  belongs_to :trackable, polymorphic: true, required: false
  belongs_to :user

  # NOTE: when the project importer creates activities, it will try to match
  # them to existing users based on the 'user email' field in the XML. If it
  # can't find any users with the given address, it will save user_id as '-1'.
  # So if you're seeing Activities in your DB with that user_id, this is why.

  # -- Validations ----------------------------------------------------------

  validates_presence_of :action, :trackable_id, :trackable_type, :user

  VALID_ACTIONS = %w[create update destroy recover]

  validates_inclusion_of :action, in: VALID_ACTIONS

  # -- Scopes ---------------------------------------------------------------

  scope :latest, -> do
    includes(:trackable).order("`activities`.`created_at` DESC").limit(10)
  end

  # -- Callbacks ------------------------------------------------------------

  # Cast action to a string so the 'inclusion' validation works with symbols
  before_validation { self.action = action.to_s if action.present? }

  # -- Class Methods -----------------------------------------------------

  # -- Instance Methods -----------------------------------------------------

  # Because Issue descends from Note but doesn't use STI, Rails's default
  # polymorphic setter will set 'trackable_type' to 'Note' when you pass an
  # Issue to trackable. This means when you load the Activity later then
  # trackable will return the wrong class. Override the default behaviour here
  # for issues:
  #
  # FIXME - ISSUE/NOTE INHERITANCE
  def trackable=(new_trackable)
    super
    self.trackable_type = "Issue" if new_trackable.is_a?(Issue)
    new_trackable
  end
end
