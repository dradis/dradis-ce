# This controller is used by the Ajax poller to retrieve changes made by other
# users.

class ActivitiesController < AuthenticatedController
  include ProjectScoped

  def index
    @page = params[:page].present? ? params[:page].to_i : 1
    @users_for_select = current_project.activities.map(&:user).uniq.union(current_project.authors.enabled)

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
    filtering_params.each do |key, value|
      next if value.blank?

      if key == 'since'
        value = DateTime.parse(value).beginning_of_day
        activities = activities.since value
      elsif key == 'before'
        value = DateTime.parse(value).end_of_day
        activities = activities.before value
      elsif ['user_id', 'trackable_type'].include? key
        activities = activities.where(key.to_sym => value)
      end
    end

    activities
  end
end
