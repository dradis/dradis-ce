module Setup
  class PasswordsController < BaseController
    # GET /setup/password
    def new
      # Remove default alert message set by AuthenticatedController
      flash.discard(:alert)

      @password_form = SharedPasswordForm.new
    end

    # POST /setup/password
    def create
      @password_form = SharedPasswordForm.new(password_params)

      if @password_form.valid?
        ::Configuration.find_by_name('admin:password').update!(
          value: ::BCrypt::Password.create(@password_form.password)
        )
        redirect_to new_setup_analytics_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def ensure_pristine
      redirect_to new_setup_analytics_path unless (::Configuration.shared_password == 'improvable_dradis')
    end

    def password_params
      params.require(:shared_password_form).permit(:password, :password_confirmation)
    end
  end
end
