class ActivityPresenter < BasePresenter
  presents :activity

  def avatar_with_link(size)
    h.link_to(avatar_image(size), 'javascript:void(0)')
  end

  def created_at_ago
    h.local_time_ago(activity.created_at)
  end

  def icon
    icon_css = %w{activity-icon fa}
    icon_css << case activity.trackable_type
                when 'Comment'
                  'fa-comment'
                when 'Evidence'
                  'fa-flag'
                when 'Issue'
                  'fa-bug'
                when 'Node'
                  'fa-folder-o'
                when 'Note'
                  'fa-file-text-o'
                else
                  ''
                end
    h.content_tag :span, nil, class: icon_css
  end

  def title
    [
      linked_email,
      verb,
      linked_model
    ].join(' ').html_safe
  end

  def render_title
    [
      linked_email,
      render_partial
    ].join(' ').html_safe
  end

  # For now we can get away with just adding 'ed' to the end of the action,
  # but this may change if we add activities whose action is an irregular
  # verb.
  def verb
    if activity.action == 'destroy'
      'deleted'
    else
      activity.action.sub(/e?\z/, 'ed')
    end
  end

  private

  def avatar_image(size)
    if activity.user
      h.image_tag(
        image_path('profile.jpg'),
        alt: activity.user,
        class: 'gravatar',
        data: { fallback_image: image_path('logo_small.png') },
        title: activity.user,
        width: size
      )
    else
      h.image_tag 'logo_small.png', width: size, alt: 'This user has been deleted from the system'
    end
  end

  # Interestingly enough we're not linking the email to anything yet as we
  # don't know what we should link to. For the time being lets just enclose
  # it in a strong tag.
  def linked_email
    if activity.user
      # h.link_to(activity.user.email, 'javascript:void(0);')
      h.content_tag :strong, activity.user
    else
      'a user who has since been deleted'
    end
  end

  def render_partial
    locals = { activity: activity, presenter: self }
    locals[activity.trackable_type.underscore.to_sym] = activity.trackable
    render partial_path, locals
  end

  def partial_path
    partial_paths.detect do |path|
      lookup_context.template_exists? path, nil, true
    end || raise("No partial found for activity in #{partial_paths}")
  end

  def partial_paths
    [
      "activities/#{activity.trackable_type.underscore}/#{activity.action}",
      "activities/#{activity.trackable_type.underscore}",
      'activities/activity'
    ]
  end

  def trackable_title
    @title ||= if activity.trackable.respond_to?(:title) && activity.trackable.title?
                 activity.trackable.title
               elsif activity.trackable.respond_to?(:label) && activity.trackable.label?
                 activity.trackable.label
               end
  end
end
