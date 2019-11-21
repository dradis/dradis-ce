# frozen_string_literal: true

module AvatarHelper
  DEFAULT_PROFILE_IMAGE = 'profile'.freeze
  DEFAULT_PROFILE_IMAGE_SIZE = 80

  # Gravatar will use a default image if one is not found. Having gravatar serve
  # the default image is not desired. Instead force an error by using a bad
  # default url and let our fallback image code take effect.
  def avatar_url(user, options = {})
    return image_url(DEFAULT_PROFILE_IMAGE) if user.nil? || !user.email.include?('@')

    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    size = options.fetch(:size, DEFAULT_PROFILE_IMAGE_SIZE).to_i * 2 # Retina displays mean dot density can be higher.
    "https://secure.gravatar.com/avatar/#{gravatar_id}.png?r=PG&s=#{size}&d=#{image_url(DEFAULT_PROFILE_IMAGE)}"
  end

  def avatar_image(user, options = {})
    alt            = options.fetch(:alt, I18n.t(user ? :alt : :removed, name: user.try(:name), scope: 'helpers.avatar_helper'))
    fallback_image = options.fetch(:fallback_image, image_url(DEFAULT_PROFILE_IMAGE))
    include_name   = options.fetch(:include_name, false)
    inline_onerror = options.fetch(:inline_onerror, false)
    klass          = options.fetch(:class, 'gravatar')
    size           = options.fetch(:size, DEFAULT_PROFILE_IMAGE_SIZE)
    title          = options.fetch(:title, user.try(:name))

    opts = {
      alt: alt,
      data: { fallback_image: fallback_image },
      height: size,
      style: "width: #{size}px; height: #{size}px",
      title: title,
      width: size
    }

    opts.merge!(onerror: "this.src = '#{fallback_image}';") if inline_onerror

    content_tag :span, class: klass do
      image_tag(avatar_url(user, size: size), opts) +
        (include_name ? " #{user.try(:name)}" : '')
    end
  end
end
