module AvatarHelper
  def avatar_url(user, options = {})
    # The arguments are a noop here for CE-Pro parity.
    image_path('profile.jpg')
  end

  def avatar_image(user, options = {})
    alt            = options.fetch(:alt, "#{user.email}'s avatar")
    fallback_image = options.fetch(:fallback_image, image_path('logo_small.png'))
    include_name   = options.fetch(:include_name, false)
    size           = options.fetch(:size, 73)
    title          = options.fetch(:title, user.email)
    klass          = options.fetch(:class, 'gravatar')

    content_tag :span, class: klass do
      image_tag(
        avatar_url(user, size: size),
        alt: alt,
        data: { fallback_image: fallback_image },
        title: title,
        height: size,
        width: size
      ) + (include_name ? ' ' + user.email : '')
    end
  end

  def comment_avatars(comment)
    comment.gsub(/@\w*@\w*\.\w*/) do |capture|
      user = User.find_by(email: capture[1..-1])
      user ? avatar_image(user, size: 20, include_name: true) : capture
    end
  end
end
