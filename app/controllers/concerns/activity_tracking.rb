module ActivityTracking
  protected

  def track_activity(trackable, action, user=current_user, project=nil)
    project = current_project if project.nil? # current_project is set by ProjectScoped
    ActivityTrackingJob.perform_later(
      action: action.to_s,
      project_id: project.try(:id),
      trackable_id: trackable.id,
      trackable_type: trackable.class.to_s,
      user_id: user.id
    )
  end

  def track_created(trackable, user = current_user)
    track_activity(trackable, :create, user)
  end

  def track_updated(trackable, user = current_user)
    track_activity(trackable, :update, user)
  end

  def track_destroyed(trackable, user=current_user, project=nil)
    track_activity(trackable, :destroy, user, project)
  end

  def track_recovered(trackable, user = current_user)
    track_activity(trackable, :recover, user)
  end
end
