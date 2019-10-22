class NotificationMailer < ApplicationMailer
  default from: 'email@securityroots.com'
  default to: 'admin@securityroots.com'

  def digest
    @user = params[:user]
    @notifications = params[:notifications]

    mail to: @user.email, subject: 'Digest Email'
  end

  def instant
    @user = params[:user]
    @notifications = params[:notifications]

    mail to: @user.email, subject: 'Notifications in the last 10 minutes.'
  end
end
