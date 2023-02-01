module Setup
  class AnalyticsController < BaseController
    include Analytic
    before_action :set_analytics_config_value, only: [:create, :toggle]

    def new; end

    def create
      if @analytics_config.save
        redirect_to login_path, notice: 'All done. May the findings for this project be plentiful!'
      else
        flash[:alert] = @analytics_config.errors.full_messages.join('; ')
        render :new
      end
    end

    def toggle
      if @analytics_config.save
        redirect_to project_event_tracking_index_path(1), notice: notice_message
      else
        redirect_to project_event_tracking_index_path(1), alert: @analytics_config.errors.full_messages.join('; ')
      end
    end

    private

    def ensure_pristine
      redirect_to project_path(1) if ::Configuration.find_by(name: 'admin:analytics').present?
    end

    def set_analytics_config_value
      @analytics_config.value = ActiveModel::Type::Boolean.new.cast(params[:analytics]) ? 1 : 0
    end

    def notice_message
      "Event tracking successfully #{params[:analytics] == 'true' ? 'enabled' : 'disabled'}!"
    end
  end
end
