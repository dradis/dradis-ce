module Setup
  class AnalyticsController < BaseController
    before_action :find_or_initialize_analytics

    def new
    end

    def create
      validate_analytics_params
      @analytics_config.value = params[:opt_in]

      respond_to do |format|
        if @analytics_config.save
          format.html {
            redirect_to login_path
            flash[:notice] = 'All done. May the findings for this project be plentiful!'
          }
        else
          format.html {
            # flash[:notice] = @analytics_config.errors.full_messages.join('; ')
            # render :new
            raise 'Invalid opt_in selection'
          }
        end
      end
    end

    private
    def ensure_pristine
      redirect_to project_path(1) if ::Configuration.find_by(name: 'analytics').present?
    end

    def find_or_initialize_analytics
      @analytics_config = ::Configuration.find_or_initialize_by(name: 'analytics')
    end

    def validate_analytics_params
      raise 'Invalid opt_in selection' unless ['true', 'false'].include? params[:opt_in]
    end
  end
end
