class EventTrackingController < AuthenticatedController
  include ProjectScoped
  include Analytic

  def index; end

  def toggle
    @analytics_config.value = params[:analytics]
    if @analytics_config.save
      redirect_to project_event_tracking_index_path, notice: notice_message
    else
      redirect_to project_event_tracking_index_path, alert: @analytics_config.errors.full_messages.join('; ')
    end
  end

  protected

  def notice_message
    "Event tracking successfully #{params[:analytics] == 'true' ? 'enabled' : 'disabled'}!"
  end
end
