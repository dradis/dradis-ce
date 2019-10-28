class DigestMailer
  DIGEST_INTERVAL   = 1.day
  INSTANT_INTERVAL  = 10.minutes

  def self.send_digests
    digest_users = User.includes(:notifications).all
    digest_users.each do |user|
      DigestMailer.new(user: user, type: :digest).send
    end
  end

  def self.send_instants
    instant_users = User.includes(:notifications).all
    instant_users.each do |user|
      DigestMailer.new(user: user, type: :instant).send
    end
  end

  def initialize(type:, user:)
    @type = type
    @user = user
  end

  attr_accessor :type, :user

  def send
    # FIXME: This only applies to notifications coming from a comment
    notifications = user.notifications.
      where('created_at >= ?', Time.now - interval).
      includes(notifiable: :commentable).
      unread.
      newest

    notifications = notifications.group_by { |n| n.notifiable.commentable }

    NotificationMailer.with(user: user, notifications: notifications).
      digest.
      deliver_now
  end


  private

  def interval
    if type == :digest
      DIGEST_INTERVAL
    elsif type == :instant
      INSTANT_INTERVAL
    else
      raise 'Invalid digest type'
    end
  end
end
