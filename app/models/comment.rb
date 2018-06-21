class Comment < ApplicationRecord
  # -- Relationships --------------------------------------------------------
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  # -- Callbacks ------------------------------------------------------------
  after_create :create_subscription

  # -- Validations ----------------------------------------------------------
  validates :content, presence: true, length: { maximum: 65535 }
  validates :commentable, presence: true, associated: true
  validates :user, presence: true, associated: true

  # -- Scopes ---------------------------------------------------------------

  # -- Class Methods --------------------------------------------------------

  # -- Instance Methods -----------------------------------------------------
  def create_subscription
    Subscription.create!(
      user: user,
      subscribable: commentable
    ) unless commentable.author == user.email
  rescue ActiveRecord::RecordNotUnique
    # Don't worry about dupes
  end
end
