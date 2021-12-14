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

      redirect_to login_path
    end

    private
    def ensure_pristine
      redirect_to project_path(1) unless (Evidence.count == 0) && (Issue.count == 0) && (Node.count == 0) && (Note.count == 0)
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
