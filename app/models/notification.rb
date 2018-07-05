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
  scope :newest,  -> { limit(7).order(created_at: :desc) }

  # -- Class Methods --------------------------------------------------------

  # -- Instance Methods -----------------------------------------------------
  alias_method :user, :recipient

  def read?
    self.read_at
  end

  def unread?
    !self.read?
  end

  # See activity.rb
  def notifiable=(new_notifiable)
    super
    self.notifiable_type = "Issue" if new_notifiable.is_a?(Issue)
    new_notifiable
  end

end
