module Setup
  class KitsController < BaseController
    before_action :set_kit, only: :create

    def new
    end

    def create
      case @kit
      when :none
        Tag::DEFAULT_TAGS.each { |name| Tag.create!(name: name) } unless defined?(Dradis::Pro)
      when :owasp, :welcome
        kit_folder = Rails.root.join('lib', 'tasks', 'templates', @kit.to_s)
        logger = Log.new.info("Loading #{title(@kit)} kit...")

        # Before we import the Kit we need at least 1 user
        User.create!(email: 'adama@dradis.com') unless defined?(Dradis::Pro)
        KitImportJob.perform_later(kit_folder.to_s, logger: logger)
      end

      mark_as_done
      flash[:notice] = 'All done. May the findings for this project be plentiful!'
      redirect_to login_path
    end

    private
    def ensure_pristine
      defined?(Dradis::Pro) ? ensure_pristine_pro : ensure_pristine_ce
    end

    def ensure_pristine_ce
      redirect_to project_path(1) unless Node.count.zero?
    end

    def mark_as_done
      defined?(Dradis::Pro) ? mark_as_done_pro : mark_as_done_ce
    end

    def mark_as_done_ce
      # weaksauce alert: this creates a Node which flags the Setup as done.
      Project.new.issue_library
    end

    def set_kit
      if %w{none owasp welcome}.include?(params[:kit])
        @kit = params[:kit].to_sym
      else
        render :new
      end
    end

    def title(kit)
      { owasp: 'OWASP', welcome: 'Welcome' }[kit]
    end
  end
end
