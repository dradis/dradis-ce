# This controller is used by the Ajax poller to retrieve changes made by other
# users.

class ActivitiesController < AuthenticatedController
  include ProjectScoped

  def index
    @page = params[:page].present? ? params[:page].to_i : 1
    @users_for_select = current_project.activities.map(&:user).union(current_project.authors.enabled)

    activities = current_project.activities.includes(:trackable)
    activities = filter_activities(activities)
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

  private

  def filtering_params
    params.permit(:user_id, :trackable_type, :since, :before)
  end

  def filter_activities(activities)
    if params[:since].present? && valid_date?(params[:since])
      activities = activities.since(DateTime.parse(params[:since]).beginning_of_day)
    end

    if params[:before].present? && valid_date?(params[:before])
      activities = activities.before(DateTime.parse(params[:before]).end_of_day)
    end

    if params[:user_id].present?
      activities = activities.where(user_id: params[:user_id])
    end

    if params[:trackable_type].present?
      activities = activities.where(trackable_type: params[:trackable_type])
    end

    activities
  end

  def valid_date?(date_string)
    Date.parse(date_string)
  rescue ArgumentError
    false
  end
end
