# This controller is used by the Ajax poller to retrieve changes made by other
# users.

class ActivitiesController < AuthenticatedController
  include ProjectScoped
  #before_action :set_start_date_and_end_date, only: :index

  def index
    @page = params[:page].present? ? params[:page].to_i : 1

    #Initiate empty array for activities on all pages
    @activities = []
    current_activities = current_project.activities.count 

    #Calculating current number of pages since we're using Kaminari's default paging
    current_pages = (current_activities / Kaminari.config.default_per_page.to_f).ceil

    @can_load_more = @page < current_pages

    (1..current_pages).each do |page_number|
      activities = current_project.activities
                                  .includes(:trackable)
                                  .order(created_at: :desc)
                                  .page(page_number)
                                  
      @activities += activities.to_a
    end

    #Search filter by user logic and trackable_type only keeping activities that match the condition
    @activities = @activities.select { |activity| activity.user_id == params[:user_id].to_i } if params[:user_id].present?
    @activities = @activities.select { |activity| activity.trackable_type == params[:trackable_type] } if params[:trackable_type].present?

    @activities_groups = @activities.group_by do |activity|
      activity.created_at.strftime(Activity::ACTIVITIES_STRFTIME_FORMAT)
    end
    filter_by_date_range(@activities_groups)
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

  def filter_by_date_range(activities)
    @start_date = params[:start_date].present? ? DatetimeHelper.parse(params[:start_date]) : nil
    @end_date = params[:end_date].present? ? DatetimeHelper.parse(params[:end_date]) : nil
    #Condition to select groups based on time
    if @start_date && @end_date.present?
    @activities_groups = @activities_groups.select do |date, activities| 
      DatetimeHelper.parse(date) >= @start_date && DatetimeHelper.parse(date) <= @end_date
    end
    elsif @start_date
      @activities_groups = @activities_groups.select do |date, activities|
        DatetimeHelper.parse(date) == @start_date
      end
    end
  end
end
