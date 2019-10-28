class NotificationMailer < ApplicationMailer
  default from: 'email@securityroots.com'
  default to: 'admin@securityroots.com'

  before_action :set_inline_attachments

  def digest
    @user = params[:user]
    @notifications = params[:notifications]
    count = @notifications.count
    @presenters = DigestPresenter.build_presenters(@notifications, view_context)

    mail to: @user.email, subject: "You have #{count} of unread #{'notification'.pluralize(count)}"
  end

  private

  def set_inline_attachments
    attachments.inline['profile'] = File.read(Rails.root.join('app/assets/images/profile.jpg'))
    attachments.inline['logo_small'] = File.read(Rails.root.join('app/assets/images/logo_small.png'))
    attachments.inline['DradisCE_full_small'] = File.read(Rails.root.join('app/assets/images/DradisCE_full_small.png'))
  end
end
