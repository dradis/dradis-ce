module AvatarHelper
  def avatar_url(user, options = {})
    if user.nil?
      image_path('profile.png')
    else
      gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      size = options.fetch(:size, 64).to_i
      "https://secure.gravatar.com/avatar/#{gravatar_id}.png?r=PG&s=#{size}"
    end
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
        width: size,
        style: "width: #{size}px; height: #{size}px"
      ) + (include_name ? ' ' + user.try(:name) : '')
    end
  end

  def comment_avatars(comment)
    # Support both concers/commented Comments collection for most views
    # as well as rendering 1-off's for polling and ajax requests.
    collection = comments ? comments.map(&:content) : Array(comment)
    matcher, rules = mentions_builder(collection)
    comment.gsub(matcher, rules)
  end

  def comment_formatter(comment)
    comment_avatars(simple_format(h(comment))).html_safe
  end
end
