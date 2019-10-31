class NotificationMailerPreview < ActionMailer::Preview
  def digest
    @user = User.first
    @notifications = @user.notifications.for_digest(30.days)
    @type = :digest
    ActionMailer::Base.default_url_options[:host] = 'dradis-framework.dev'
    NotificationMailer.with(user: @user, notifications: @notifications, type: @type).digest
  end
end
