class Comment < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  # -- Callbacks ------------------------------------------------------------
  after_create :create_notifications
  after_create :create_subscription

  # -- Validations ----------------------------------------------------------
  validates :content, length: { maximum: 65535 }
  validates :commentable, presence: true, associated: true
  validates :user, presence: true, associated: true

  # -- Scopes ---------------------------------------------------------------

  # -- Class Methods --------------------------------------------------------

  # -- Instance Methods -----------------------------------------------------
  def create_notifications
    CreateNotificationsJob.perform_later(self)
  end

  def create_subscription
    Subscription.create(
      user: self.user,
      subscribable: self
    )
  end
end
