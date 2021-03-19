class ActivityPresenter < BasePresenter
  presents :activity

  def activity_day
    h.local_date(activity.created_at.to_date, format: Activity::ACTIVITIES_STRFTIME_FORMAT, data: { behavior: 'activity-day-value' })
  end

  def activity_time
    h.local_time(activity.created_at, format: '%l:%M%P')
  end

  def avatar_with_link(size)
    h.link_to(avatar_image(activity.user, size: size), 'javascript:void(0)')
  end

  def comment_path(anchor: false)
    # FIXME - ISSUE/NOTE INHERITANCE
    # Would like to use only `commentable.respond_to?(:node)` here, but
    # that would return a wrong path for issues
    comment         = activity.trackable
    commentable     = comment.commentable
    path_to_comment =
      if commentable.respond_to?(:node) && !commentable.is_a?(Issue)
        [current_project, commentable.node, commentable]
      elsif commentable.is_a?(Card)
        [current_project, commentable.board, commentable.list, commentable]
      else
        [current_project, commentable]
      end

    anchor = dom_id(comment) if anchor
    polymorphic_path(
      path_to_comment,
      anchor: anchor
    )
  end

  def created_at_ago
    h.local_time_ago(activity.created_at)
  end

  def icon
    icon_css = %w{activity-icon fa}
    icon_css << case activity.trackable_type
                when 'Board', 'List', 'Card'
                  'fa-trello'
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

  # Interestingly enough we're not linking the email to anything yet as we
  # don't know what we should link to. For the time being lets just enclose
  # it in a strong tag.
  def linked_email
    if activity.user
      # h.link_to(activity.user.email, 'javascript:void(0);')
      h.content_tag :strong, activity.user.email
    else
      'a user who has since been deleted'
    end
  end

  def partial_path
    partial_paths.detect do |path|
      lookup_context.template_exists? path, nil, true
    end || raise("No partial found for activity in #{partial_paths}")
  end

  def partial_paths
    [
      "activities/#{activity.trackable_type.underscore}/#{activity.action}",
      'activities/activity'
    ] +
    ["#{activity.trackable_type.underscore.downcase.pluralize}/activities/#{trackable_name}"]
  end

  def render_partial
    locals = {activity: activity, presenter: self}
    locals[trackable_name] = activity.trackable
    render partial_path, locals
  end

  def trackable_name
    # Models from plugins are namespaced, e.g. "Dradis::Plugins::ModelName"
    # and activity.trackable_type.underscore will return "dradis/plugins/model_name".
    # So we demodulize it first to return "model_name" before passing in as locals.
    @trackable_name ||= activity.trackable_type.demodulize.underscore.to_sym
  end

  def trackable_title
    @title ||= if activity.trackable.respond_to?(:title) && activity.trackable.title?
                 activity.trackable.title
               elsif activity.trackable.respond_to?(:label) && activity.trackable.label?
                 activity.trackable.label
               end
  end
end
