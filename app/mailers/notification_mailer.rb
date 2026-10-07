class NotificationMailer < ApplicationMailer
  helper :avatar

  before_action :set_inline_attachments

  def digest
    @user = params[:user]
    @notifications = params[:notifications]
    @type = params[:type]

    mail to: @user.email, subject: 'You have unread notifications.'
  end

  private

  def set_inline_attachments
    attachments.inline['dradis_logo.png'] =
      File.read(
        Rails.root.join('app', 'assets', 'images', 'logo_full_small.png')
      )
  end
end
