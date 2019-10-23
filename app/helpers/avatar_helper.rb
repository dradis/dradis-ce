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
    # Match any string that starts with an @ has another @ and ends with whitespace
    emails = comment.scan(/@(\S*@\S*)\s/).flatten.uniq
    users = current_project.authors.where(email: emails)

    replacement_rules = users.each_with_object({}) do |user, hash|
      hash['@' + user.email] = avatar_image(user, size: 20, include_name: true)
    end

    matcher = /#{users.map { |user| '@' + user.email }.join('|')}/
    comment.gsub(matcher, replacement_rules)
  end
end
