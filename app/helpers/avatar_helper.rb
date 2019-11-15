# frozen_string_literal: true

module AvatarHelper
  DEFAULT_PROFILE_IMAGE = ActionController::Base.helpers.image_path('profile')

  # Gravatar will use a default image if one is not found. Having gravatar serve
  # the default image is not desired. Instead force an error by using a bad
  # default url and let our fallback image code take effect.
  def avatar_url(user, options = {})
    return DEFAULT_PROFILE_IMAGE if user.nil?

    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    size = options.fetch(:size, 80).to_i
    "https://secure.gravatar.com/avatar/#{gravatar_id}.png?r=PG&s=#{size}&d=forceErrorOnDefault"
  end

  def nil_user_avatar(klass, size)
    removed_msg = 'This user has been deleted from the system'

    content_tag :span, class: klass do
      image_tag(
        DEFAULT_PROFILE_IMAGE,
        alt: removed_msg,
        title: removed_msg,
        width: size
      )
    end
  end

  def avatar_image(user, options = {})
    klass          = options.fetch(:class, 'gravatar')
    size           = options.fetch(:size, 73)

    return nil_user_avatar(klass, size) if user.nil?

    alt            = options.fetch(:alt, "#{user.email}'s avatar")
    fallback_image = options.fetch(:fallback_image, DEFAULT_PROFILE_IMAGE)
    gravatar_size  = options.fetch(:gravatar_size, 80)
    include_name   = options.fetch(:include_name, false)
    title          = options.fetch(:title, user.email)

    content_tag :span, class: klass do
      image_tag(
        avatar_url(user, size: gravatar_size),
        alt: alt,
        data: { fallback_image: fallback_image },
        height: size,
        style: "width: #{size}px; height: #{size}px",
        title: title,
        width: size
      ) + (include_name ? ' ' + user.try(:name) : '')
    end
  end

  def mention_matcher
    @mention_matcher ||= begin
      users = current_project.authors.all.select(:email, :name)

      matcher = /#{users.map { |user| '@' + user.email }.join('|')}/
      rules = users.each_with_object({}) do |user, hash|
        hash['@' + user.email] = avatar_image(user, size: 20, include_name: true, class: 'gravatar gravatar-inline')
      end

      [matcher, rules]
    end
  end

  def mentions_formatter(content)
    matcher, rules = mention_matcher
    content.gsub(matcher, rules)
  end

  def comment_formatter(comment)
    mentions_formatter(simple_format(h(comment))).html_safe
  end
end
