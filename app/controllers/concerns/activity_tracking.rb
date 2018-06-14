module ActivityTracking

  protected

  def track_activity(trackable, action, user=current_user)
    Activity.create!(
      trackable: trackable,
      user:      user,
      action:    action.to_s
    )

    ActiveSupport::Notifications.instrument(
      'activity',
      action: action,
      trackable: trackable,
      user: user
    )
  end

  def track_created(trackable, user=current_user)
    track_activity(trackable, :create, user)
  end

  def track_updated(trackable, user=current_user)
    track_activity(trackable, :update, user)
  end

  def track_destroyed(trackable, user=current_user)
    track_activity(trackable, :destroy, user)
  end

  def track_recovered(trackable, user=current_user)
    track_activity(trackable, :recover, user)
  end

end
