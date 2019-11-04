class NotificationMailerPreview < ActionMailer::Preview
  def digest
    NotificationMailer.with(user: User.first).digest
  end
end

