module Setup
  class KitsController < BaseController
    before_action :set_kit, only: :create

    def new
    end

    def create
      case @kit
      when :none
        # weaksauce alert: this creates a Node which flags the Setup as done.
        Project.new.issue_library
      when :welcome
        kit_folder = Rails.root.join('lib', 'tasks', 'templates', 'welcome').to_s
        logger = Log.new.info('Loading Welcome kit...')
        # Before we import the Kit we need at least 1 user
        User.create!(email: 'adama@dradisframework.com')
        KitImportJob.perform_later(kit_folder, logger: logger)
      end
      EventTrackingJob.perform_later(event_name: 'Setup Completed')
      flash[:notice] = 'All done. May the findings for this project be plentiful!'
      redirect_to login_path
    end

    private
    def ensure_pristine
      redirect_to project_path(1) unless Node.count.zero?
    end

    def set_kit
      if %w{none welcome}.include?(params[:kit])
        @kit = params[:kit].to_sym
      else
        render :new
      end
    end
  end
end
