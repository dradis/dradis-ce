class NotificationMailerPreview < ActionMailer::Preview
  def instant
    NotificationMailer.with(user: User.first).instant
  end

  def digest
    NotificationMailer.with(user: User.first).digest
  end
end