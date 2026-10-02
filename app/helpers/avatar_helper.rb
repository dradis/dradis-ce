# frozen_string_literal: true

module AvatarHelper
  DEFAULT_PROFILE_IMAGE = 'avatar.png'.freeze
  DEFAULT_PROFILE_IMAGE_SIZE = 80

  def avatar_image(user, opt = {})
    opt.reverse_merge!( # Defaults if not provided
      alt: I18n.t(user ? :alt : :removed, name: user.try(:name), scope: 'helpers.avatar_helper'),
      fallback_image: image_path(DEFAULT_PROFILE_IMAGE),
      include_name: false,
      size: DEFAULT_PROFILE_IMAGE_SIZE,
      title: user.try(:name)
    ).merge!( # Additive properties
      class: ['gravatar', opt[:class]].compact.join(' '),
      style: ["width: #{opt[:size]}px; height: #{opt[:size]}px;", opt[:style]].compact.join(' '),
    )

    img_properties = {
      alt: opt[:alt],
      data: { controller: 'gravatar', gravatar_url: avatar_url(user, size: opt[:size]) },
      height: opt[:size],
      referrerpolicy: 'no-referrer',
      style: opt[:style],
      title: opt[:title],
      width: opt[:size]
    }

    content_tag :span, class: opt[:class] do
      image_tag(user.try(:avatar).presence || opt[:fallback_image], img_properties) +
        (opt[:include_name] ? " #{user.try(:name)}" : '')
    end
  end

  def avatar_url(user, options = {})
    return user.avatar if user.try(:avatar).present?
    return image_path(DEFAULT_PROFILE_IMAGE) if user.nil? || !user.email.include?('@')

    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    size = options.fetch(:size, DEFAULT_PROFILE_IMAGE_SIZE).to_i * 2 # Retina displays mean dot density can be higher.
    "https://secure.gravatar.com/avatar/#{gravatar_id}?r=PG&s=#{size}&d=404"
  end

  def tribute_hash(users)
    users.map do |user|
      {
        key: h(user.email),
        value: user.email,
        avatar_url: avatar_url(user)
      }
    end
  end
end
