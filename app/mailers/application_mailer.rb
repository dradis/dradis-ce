class ApplicationMailer < ActionMailer::Base
  helper EmailAvatars

  layout 'mailer'
end
