# This controller is used by the Ajax poller to retrieve changes made by other
# users.

class ActivitiesController < AuthenticatedController
  include ProjectScoped

  def index
    @page = params[:page].present? ? params[:page].to_i : 1

    activities = current_project.activities
                                .includes(:trackable)
                                .order(created_at: :desc)
                                .page(@page)

    activities = ActivityFilterService.new(activities, filter_params).call

    @users = User.all
    @trackable_types = current_project.activities.pluck(:trackable_type).uniq.sort

    @activities_groups = activities.group_by do |activity|
      activity.created_at.strftime(Activity::ACTIVITIES_STRFTIME_FORMAT)
    end

    respond_to do |format|
      format.html
      format.js
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

  def filter_params
    params.fetch(:filter, {}).permit(:user_id, :trackable_type, :date, :start_date, :end_date)
  end
end
