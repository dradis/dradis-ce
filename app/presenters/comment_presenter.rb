class CommentPresenter < BasePresenter
  presents :comment

  def avatar_with_link(size)
    h.link_to(avatar_image(size), 'javascript:void(0)')
  end

  def created_at_ago
    h.local_time_ago(comment.created_at)
  end

  # Interestingly enough we're not linking the email to anything yet as we
  # don't know what we should link to. For the time being lets just enclose
  # it in a strong tag.
  def linked_email
    if comment.user
      # h.link_to(activity.user.email, 'javascript:void(0);')
      h.content_tag :strong, comment.user.email
    else
      'a user who has since been deleted'
    end
  end

  def render_content
    comment.content
    # TODO: render_partial
  end

  private

  def avatar_image(size)
    if comment.user
      h.image_tag(
        image_path('profile.jpg'),
        alt: comment.user,
        class: 'gravatar',
        data: { fallback_image: image_path('logo_small.png') },
        title: comment.user,
        width: size
      )
    else
      h.image_tag 'logo_small.png', width: size, alt: 'This user has been deleted from the system'
    end
  end
end
