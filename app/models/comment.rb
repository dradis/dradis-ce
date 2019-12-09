class Comment < ApplicationRecord
  include Notifiable

  MENTION_PATTERN = /[a-z0-9][a-z0-9\-@\.]*/.freeze

  # -- Relationships --------------------------------------------------------
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  # -- Callbacks ------------------------------------------------------------
  after_create :create_subscription

  # -- Validations ----------------------------------------------------------
  validates :content, presence: true, length: { maximum: DB_MAX_TEXT_LENGTH }
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
      subscribe_mentioned()
      create_notifications(action: :mention, recipients: mentions)

      subscribers = commentable.subscriptions.where.not(user: user).map(&:user)
      create_notifications(action: :create, recipients: subscribers - mentions)
    end
  end

  def mentions
    @mentions = nil if content_changed?
    @mentions ||= begin
      emails = []
      HTML::Pipeline::MentionFilter.mentioned_logins_in(content, MENTION_PATTERN) do |_, login, _|
        emails << login
      end

      project = commentable.project
      project.testers_for_mentions.where(email: emails.uniq)
    end
  end

  private

  def subscribe_mentioned
    mentions.each do |mention|
      Subscription.subscribe(user: mention, to: commentable)
    end
  end
end
