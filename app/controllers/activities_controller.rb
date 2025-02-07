# This controller is used by the Ajax poller to retrieve changes made by other
# users.

class ActivitiesController < AuthenticatedController
  include ProjectScoped
  before_action :set_start_date, only: :index

  def index
    @page = params[:page].present? ? params[:page].to_i : 1
    
    activities = current_project.activities
                                .includes(:trackable)
                                .order(created_at: :desc)
                                .page(@page)

    #Search filter logic using the scopes
    activities = activities.by_user(params[:user_id])

    @activities_groups = activities.group_by do |activity|
      activity.created_at.strftime(Activity::ACTIVITIES_STRFTIME_FORMAT)
    end

    filter_by_start_date(@activities_groups)
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

  def set_start_date 
    @start_date = params[:start_date].present? ? DatetimeHelper.parse(params[:start_date]) : nil
  end

  def filter_by_start_date(activities)
    #Condition to select groups based on time
    if @start_date
      @activities_groups = @activities_groups.select do |date, activities| 
        DatetimeHelper.parse(date) == @start_date
      end
    end
  end
end
