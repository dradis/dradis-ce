class NotificationMailer < ApplicationMailer
  helper :avatar

  before_action :set_inline_attachments

  def digest
    @notifications = params[:notifications]
    @user = params[:user]
    set_login_path_for_user
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

  def set_login_path_for_user # careful not to override login_path route helper
    login_url
  end
end
