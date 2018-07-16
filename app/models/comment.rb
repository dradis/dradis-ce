class Comment < ApplicationRecord
  include Notifiable

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
  # Because Issue descends from Note but doesn't use STI, Rails's default
  # polymorphic setter will set 'commentable_type' to 'Note' when you pass an
  # Issue to commentable. This means when you load the Activity later then
  # commentable will return the wrong class. Override the default behaviour here
  # for issues:
  #
  # FIXME - ISSUE/NOTE INHERITANCE
  def commentable=(new_commentable)
    super
    self.commentable_type = 'Issue' if new_commentable.is_a?(Issue)
    new_commentable
  end

  def create_subscription
    Subscription.subscribe(user: user, to: commentable)
  end

  def notify(action)
    case action.to_s
    when 'create'
      subscribers = commentable.subscriptions.where.not(user: user).map(&:user)
      create_notifications(action: :create, recipients: subscribers)
      broadcast_notifications(recipients: subscribers)
    end
  end
end
