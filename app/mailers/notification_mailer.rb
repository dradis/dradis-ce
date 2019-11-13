class NotificationMailer < ApplicationMailer
  include AvatarHelper

  before_action :set_inline_attachments

  def digest
    @user = params[:user]
    @notifications = params[:notifications]
    @type = params[:type]

    set_user_avatar

    mail to: @user.email, subject: 'You have unread notifications.'
  end

  private

  def find_asset(name)
    Rails.application.assets.find_asset(name).pathname
  end

  def set_inline_attachments
    attachments.inline['dradis_logo'] =
      if defined?(Dradis::Pro)
        File.read(find_asset('DradisPro_full_small.png'))
      else
        File.read(find_asset('DradisCE_full_small.png'))
      end
  end

  def set_user_avatar
    @avatar_url = avatar_url(@user)
  end
end
