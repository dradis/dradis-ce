# frozen_string_literal: true

module EmailAvatars
  include AvatarHelper

  def avatar_image(user, opt = {})
    path = Avatar.file_path(email: user.email) if defined?(Avatar) && user.try(:avatar).present?
    path = Rails.root.join('app/assets/images', AvatarHelper::DEFAULT_PROFILE_IMAGE) unless path && File.file?(path)

    super(user, opt.merge(gravatar: false, src: inline_email_image(path)))
  end

  def inline_email_image(path)
    filename = File.basename(path)
    attachments.inline[filename] = File.binread(path) unless attachments[filename]
    attachments[filename].url
  end
end
