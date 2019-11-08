class DigestSender
  DIGEST_INTERVAL   = 1.day
  INSTANT_INTERVAL  = 10.minutes

  def self.send_digests
    daily_users.each do |user|
      DigestSender.new(user: user, type: :digest).send
    end
  end

  def self.send_instants
    instant_users.each do |user|
      DigestSender.new(user: user, type: :instant).send
    end
  end

  def initialize(type:, user:)
    @type = type
    @user = user
  end

  attr_accessor :type, :user

  def send
    notifications = user.notifications.for_digest(interval)
    NotificationMailer.with(user: user, notifications: notifications, type: type).
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

  def daily_users
    User.where('preferences LIKE "%digest_frequency: daily%"')
  end

  def instant_users
    User.where('preferences LIKE "%digest_frequency: instant%"')
  end
end
