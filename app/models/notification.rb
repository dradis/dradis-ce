class Notification < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  belongs_to :actor, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  # -- Callbacks ------------------------------------------------------------

  # -- Validations ----------------------------------------------------------
  validates :action, presence: true
  validates :actor, presence: true, associated: true
  validates :notifiable, presence: true, associated: true
  validates :recipient, presence: true, associated: true

  # -- Scopes ---------------------------------------------------------------
  scope :unread,  -> { where(read_at: nil) }
  scope :read,    -> { where.not(read_at: nil) }

  # -- Class Methods --------------------------------------------------------

  # -- Instance Methods -----------------------------------------------------
  def read?
    self.read_at
  end
end
