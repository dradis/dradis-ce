module Setup
  class AnalyticsController < BaseController
    def new
    end

    def create
      flash[:notice] = 'All done. May the findings for this project be plentiful!'
      redirect_to login_path
    end

    private
    def ensure_pristine
      #redirect_to project_path(1) unless anyalyics are neither opted in nor out
    end
  end
end
