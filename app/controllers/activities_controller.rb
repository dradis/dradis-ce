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

    # Apply filters on All Activities
    @user_id = params[:user_id]
    @trackable_type = params[:trackable_type]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @specific_date = params[:specific_date]

    activities = activities.by_user(@user_id)
                           .by_trackable_type(@trackable_type)
                           .by_date_range(@start_date, @end_date)
                           .on_specific_date(@specific_date)

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
