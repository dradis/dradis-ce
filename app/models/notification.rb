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
  scope :newest,  -> { order(created_at: :desc) }
  scope :read,    -> { where.not(read_at: nil) }
  scope :unread,  -> { where(read_at: nil) }

  # All unread notifications within a given span of time
  scope :since, -> (time_ago = 1.day.ago) {
    where('created_at >= ?', time_ago).unread.newest
  }

  # -- Class Methods --------------------------------------------------------

  def self.mark_all_as_read!
    # update_all doesnt update timestamps, so do it manually to bust the cache:
    update_all(read_at: Time.now, updated_at: Time.now)
  end

  def self.for_digest(interval)
    NotificationGroup.new(since(interval).includes(notifiable: :commentable))
  end

  def self.preload_objects(notifications)
    # Eager loading multiple polymorphic associations
    # https://stackoverflow.com/questions/42773318/eager-load-depending-on-type-of-association-in-ruby-on-rails

    ActiveRecord::Associations::Preloader.new.preload(
      notifications.select { |notification| notification.notifiable_type == 'Card' },
      [:actor, :notifiable]
    )
    ActiveRecord::Associations::Preloader.new.preload(
      notifications.select { |notification| notification.notifiable_type == 'Comment' },
      [:actor, notifiable: [:user, :commentable]]
    )
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
