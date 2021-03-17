# This controller is used by the Ajax poller to retrieve changes made by other
# users.

class ActivitiesController < AuthenticatedController
  include ProjectScoped

  def index
    @page = params[:page].present? ? params[:page].to_i : 1

    activities = Kaminari.paginate_array(
      Activity.includes(:trackable).order(created_at: :desc).by_project(current_project)
    ).page(@page)

    @activities_groups = activities.group_by do |activity|
      activity.created_at.strftime(Activity::ACTIVITIES_STRFTIME_FORMAT)
    end
  end

  def poll
    @this_poll  = Time.now.to_i
    @activities = Activity.where(
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
