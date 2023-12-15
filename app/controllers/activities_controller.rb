# This controller is used by the Ajax poller to retrieve changes made by other
# users.

class ActivitiesController < AuthenticatedController
  include ProjectScoped
  include ActivitiesHelper

  def index
    @page = params[:page].present? ? params[:page].to_i : 1

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

  def period_start
    DateTime.parse params[:period_start]
  end

  def period_end
    if params[:period_end].empty?
      DateTime.now
    else
      DateTime.parse params[:period_end]
    end
  end

  def filtering_params
    params.slice(:user, :type, :period_start, :period_end)
  end

  def filter_activities(activities)
    filtering_params.each do |key, value|
      next if value.blank?

      if key == 'period_start'
        value = DateTime.parse(value).beginning_of_day
      elsif key == 'period_end'
        value = DateTime.parse(value).end_of_day
      end

      activities = activities.send("by_#{key}", value)
    end

    activities
  end
end
