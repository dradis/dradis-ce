class DigestSender
  DAILY_INTERVAL    = 1.day.ago
  INSTANT_INTERVAL  = 10.minutes.ago

  attr_accessor :type, :user

  # -- Class Methods --------------------------------------------------------
  def self.digest_users(type:)
    User.includes(:notifications).where("preferences LIKE '%digest_frequency: #{type}%'")
  end

  def self.send_dailies
    digest_users(type: :daily).each do |user|
      DigestSender.new(user: user, type: :daily).send
    end
  end

  def self.send_instants
    digest_users(type: :instant).each do |user|
      DigestSender.new(user: user, type: :instant).send
    end
  end

  # -- Instance Methods -----------------------------------------------------
  def initialize(type:, user:)
    @type = type
    @user = user
  end

  def send
    notifications = user.notifications.for_digest(interval.ago)
    return if notifications.count == 0

    NotificationMailer.with(user: user, notifications: notifications, type: type).
      digest.
      deliver_now
  end

  private

  def interval
    if type == :daily
      DAILY_INTERVAL
    elsif type == :instant
      INSTANT_INTERVAL
    else
      raise 'Invalid digest type'
    end
  end
end
