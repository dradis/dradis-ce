module ApplicationHelper # :nodoc:
  def avatar_url
    image_path('profile.jpg')
  end

  def avatar_image(user, options = {})
    alt            = options.fetch(:alt, "#{user.email}'s avatar")
    fallback_image = options.fetch(:fallback_image, image_path('logo_small.png'))
    include_name   = options.fetch(:include_name, false)
    size           = options.fetch(:size, 73)
    title          = options.fetch(:title, user.email)

    content_tag :span, class: 'gravatar' do
      image_tag(
        avatar_url, #(user, size: size),
        alt: alt,
        data: { fallback_image: fallback_image },
        title: title,
        height: size,
        width: size
      ) + (include_name ? ' ' + user.email : '')
    end
  end
  
  def markup(text)
    return unless text.present?

    context = { }

    textile_pipeline = HTML::Pipeline.new [
      HTML::Pipeline::DradisFieldableFilter,
      HTML::Pipeline::DradisTextileFilter,
      # HTML::Pipeline::DradisCodeHighlightFilter,
      HTML::Pipeline::AutolinkFilter
    ], context

    result = textile_pipeline.call(text)
    result[:output].to_s.html_safe
  end
end
