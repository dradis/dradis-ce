class NotificationMailer < ActionMailer::Base
  INSTANT_DIGEST_INTERVAL = 10.minutes

  default from: 'email@securityroots.com'
  default to: 'admin@securityroots.com'

  def digest(user:)
    @user = user
    @notifications = digest_notifications

    @user.last_digest_email = Time.now
    @user.save

    mail to: user.email, subject: 'Digest Email'
  end

  def instant(user:)
    @user = user
    @notifications = instant_notifications

    mail to: user.email, subject: 'Notifications in the last 10 minutes.'
  end

  private

  def digest_notifications
    @user.notifications.
      where('created_at >= ?', @user.last_digest_email).
      unread.
      newest
  end

  def instant_notifications
    @user.notifications.
      where('created_at >= ?', Time.now - INSTANT_DIGEST_INTERVAL).
      unread.
      newest
  end
end
