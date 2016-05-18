module ActivityTracking

  protected

  def track_activity(trackable, action, user=current_user)
    Activity.create!(
      trackable: trackable,
      user:      user.email,
      action:    action.to_s
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

end
