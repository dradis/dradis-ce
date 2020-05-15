# This controller is used by the Ajax poller to retrieve changes made by other
# users.

class ActivitiesController < AuthenticatedController
  include ProjectScoped

  def index
    @activities_groups = Activity.all_latest.page(params[:page]).group_by do
      |activity| activity.created_at.strftime(Activity::ACTIVITIES_STRFTIME_FORMAT)
    end

    respond_to do |format|
      format.html
      format.js do
        render 'activities/_activities_groups.html.erb', locals: { activities_groups: @activities_groups }
      end
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
