class NotificationMailerPreview < ActionMailer::Preview
  def instant
    NotificationMailer.instant(User.first)
  end

  def digest
    NotificationMailer.digest(User.first)
  end
end
