# frozen_string_literal: true

module AvatarHelper
  DEFAULT_PROFILE_IMAGE = ActionController::Base.helpers.image_path('profile')
  DEFAULT_PROFILE_IMAGE_SIZE = 80

  # Gravatar will use a default image if one is not found. Having gravatar serve
  # the default image is not desired. Instead force an error by using a bad
  # default url and let our fallback image code take effect.
  def avatar_url(user, options = {})
    return DEFAULT_PROFILE_IMAGE if user.nil? || !user.email.include?('@')

    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    size = options.fetch(:size, DEFAULT_PROFILE_IMAGE_SIZE).to_i * 2 # Retna displays mean dot density can be higher.
    "https://secure.gravatar.com/avatar/#{gravatar_id}.png?r=PG&s=#{size}&d=forceErrorOnDefault"
  end

  def avatar_image(user, options = {})
    removed_msg    = 'This user has been deleted from the system'
    alt            = options.fetch(:alt, (user ? "#{user.name}'s avatar" : removed_msg))
    fallback_image = options.fetch(:fallback_image, DEFAULT_PROFILE_IMAGE)
    include_name   = options.fetch(:include_name, false)
    klass          = options.fetch(:class, 'gravatar')
    size           = options.fetch(:size, DEFAULT_PROFILE_IMAGE_SIZE)
    title          = options.fetch(:title, user.try(:name))

    content_tag :span, class: klass do
      image_tag(
        avatar_url(user, size: size),
        alt: alt,
        data: { fallback_image: fallback_image },
        height: size,
        style: "width: #{size}px; height: #{size}px",
        title: title,
        width: size
      ) + (include_name ? ' ' + user.try(:name) : '')
    end
  end
end
