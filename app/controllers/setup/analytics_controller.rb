module Setup
  class AnalyticsController < BaseController
    include Analytic

    def new; end

    def create
      @analytics_config.value = params[:analytics]

      if @analytics_config.save
        redirect_to login_path, notice: 'All done. May the findings for this project be plentiful!'
      else
        flash[:alert] = @analytics_config.errors.full_messages.join('; ')
        render :new
      end
    end

    private

    def ensure_pristine
      redirect_to project_path(1) if ::Configuration.find_by(name: 'admin:analytics').present?
    end
  end
end
