# This controller is used by the Ajax poller to retrieve changes made by other
# users.

class ActivitiesController < AuthenticatedController
  include ProjectScoped

  def index
    @page = params[:page].present? ? params[:page].to_i : 1

    activities = current_project.activities.includes(:trackable)
    activities = activities.filter_by_user_id(params[:user]) if params[:user].present?
    activities = activities.filter_by_type(params[:type]) if params[:type].present?
    activities = activities.order(created_at: :desc).page(@page)

    @activities_groups = activities.group_by do |activity|
      activity.created_at.strftime(Activity::ACTIVITIES_STRFTIME_FORMAT)
    end
  end

  def poll
    @this_poll  = Time.now.to_i
    @activities = current_project.activities.includes(:trackable).where(
      '`user_id` != (?) AND `created_at` >= (?)',
      current_user.id,
      # passing the string directly doesn't work, must be a Time object:
      Time.at(params[:last_poll].to_i)
    )

    respond_to do |format|
      format.js
    end
  end
end
