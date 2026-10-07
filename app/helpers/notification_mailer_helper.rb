# frozen_string_literal: true

module NotificationMailerHelper
  DEFAULT_EMAIL_AVATAR_URL = 'https://raw.githubusercontent.com/dradis/dradis-ce/refs/heads/develop/app/assets/images/avatar.png'.freeze

  def email_avatar_image(user, options = {})
    size = options.fetch(:size, AvatarHelper::DEFAULT_PROFILE_IMAGE_SIZE)
    source =
      if user.try(:avatar).present?
        URI.join(root_url, user.avatar).to_s
      elsif user && user.email.include?('@')
        avatar_url(user, size: size).sub('d=404', "d=#{ERB::Util.url_encode(DEFAULT_EMAIL_AVATAR_URL)}")
      else
        DEFAULT_EMAIL_AVATAR_URL
      end

    content_tag :span, class: 'gravatar' do
      image_tag(source, options.except(:size).reverse_merge(
                          alt: I18n.t(user ? :alt : :removed, name: user.try(:name), scope: 'helpers.avatar_helper'),
                          height: size,
                          referrerpolicy: 'no-referrer',
                          title: user.try(:name),
                          width: size
      ))
    end
  end
end
