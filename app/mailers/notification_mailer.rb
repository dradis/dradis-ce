class NotificationMailer < ActionMailer::Base
  default from: 'email@securityroots.com'
  default to: 'admin@securityroots.com'

  def digest(user:, notifications:)
    @user = user
    @notifications = notifications

    mail to: user.email, subject: 'Digest Email'
  end

  def instant(user:, notifications:)
    @user = user
    @notifications = notifications

    mail to: user.email, subject: 'Notifications in the last 10 minutes.'
  end
end
