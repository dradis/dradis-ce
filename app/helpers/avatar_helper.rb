# frozen_string_literal: true

module AvatarHelper
  DEFAULT_EMAIL_AVATAR_URL = 'https://raw.githubusercontent.com/dradis/dradis-ce/refs/heads/develop/app/assets/images/avatar.png'.freeze
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
      height: opt[:size],
      referrerpolicy: 'no-referrer',
      style: opt[:style],
      title: opt[:title],
      width: opt[:size]
    }

    source = user.try(:avatar).presence || opt[:fallback_image]
    if opt[:email]
      source = avatar_url(user, size: opt[:size], email: true)
    else
      img_properties[:data] = { controller: 'gravatar', gravatar_url: avatar_url(user, size: opt[:size]) }
    end

    content_tag :span, class: opt[:class] do
      image_tag(source, img_properties) +
        (opt[:include_name] ? " #{user.try(:name)}" : '')
    end
  end

  def avatar_url(user, options = {})
    if user.try(:avatar).present?
      return options[:email] ? URI.join(root_url, user.avatar).to_s : user.avatar
    end

    if user.nil? || !user.email.include?('@')
      return options[:email] ? DEFAULT_EMAIL_AVATAR_URL : image_path(DEFAULT_PROFILE_IMAGE)
    end

    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    size = options.fetch(:size, DEFAULT_PROFILE_IMAGE_SIZE).to_i * 2 # Retina displays mean dot density can be higher.
    default = options[:email] ? ERB::Util.url_encode(DEFAULT_EMAIL_AVATAR_URL) : '404'
    "https://secure.gravatar.com/avatar/#{gravatar_id}?r=PG&s=#{size}&d=#{default}"
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
