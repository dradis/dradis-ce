module Setup
  class KitsController < BaseController
    before_action :set_kit, only: :create

    def new
    end

    def create
      case @kit
      when :none
        ;
      when :welcome
        kit_file = ''
        logger = nil
        KitImportJob.perform_later(file: kit_file, logger: logger)
      end

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
