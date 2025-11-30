module Setup
  class AnalyticsController < BaseController
    def new
    end
    def create
      setting = ::Configuration.new(name: 'admin:usage_sharing')
      setting.value = ActiveModel::Type::Boolean.new.cast(params[:analytics]) ? 1 : 0

      if setting.save
        redirect_to new_setup_kit_path
      else
        flash[:alert] = "Something went wrong: #{setting.errors.full_messages.join('; ')}"
        render :new
      end
    end

    private
    def ensure_pristine
      redirect_to new_setup_kit_path unless ::Configuration.where(name: 'admin:usage_sharing').empty?
    end
  end
end
