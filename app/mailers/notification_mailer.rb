class NotificationMailer < ApplicationMailer
  default from: 'email@securityroots.com'
  default to: 'admin@securityroots.com'

  def digest
    @user = params[:user]
    @notifications = params[:notifications]

    mail to: @user.email, subject: "You have #{@notifications.count} of unread #{'notification'.pluralize(count)}"
  end
end
