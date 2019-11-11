class Notification < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  belongs_to :actor, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :notifiable, polymorphic: true
  belongs_to :project

  # -- Callbacks ------------------------------------------------------------

  # -- Validations ----------------------------------------------------------
  validates :action, presence: true
  validates :actor, presence: true, associated: true
  validates :notifiable, presence: true, associated: true
  validates :recipient, presence: true, associated: true
  validates :project, presence: true, associated: true

  # -- Scopes ---------------------------------------------------------------
  scope :newest,  -> { order(created_at: :desc) }
  scope :read,    -> { where.not(read_at: nil) }
  scope :unread,  -> { where(read_at: nil) }

  # -- Class Methods --------------------------------------------------------

  def self.mark_all_as_read!
    # update_all doesnt update timestamps, so do it manually to bust the cache:
    update_all(read_at: Time.now, updated_at: Time.now)
  end

  # -- Instance Methods -----------------------------------------------------
  def read?
    self.read_at
  end

  def read!(time = Time.now)
    return if self.read_at
    self.update_attribute :read_at, time
  end
end
