module Setup
  class PasswordsController < BaseController
    before_action :validate_password, only: :create

    # GET /setup/password
    def new
      # Remove default alert message set by AuthenticatedController
      flash.discard(:alert)
    end

    # POST /setup/password
    #
    # @password was set by the ensure_valid_password filter
    def create
      setting       = ::Configuration.find_by_name('admin:password')
      setting.value = ::BCrypt::Password.create(@password)

      if setting.save
        redirect_to new_setup_analytics_path
      else
        flash[:alert] = "Something went wrong: #{setting.errors.full_messages.join('; ')}"
        render :new
      end
    end

    private
    def ensure_pristine
      redirect_to new_setup_analytics_path unless (::Configuration.shared_password == 'improvable_dradis')
    end

    # Ensure that the user has provided a valid password, that the password
    # matches the confirmation and that they are not empty.
    #
    # FIXME: we should move this to a form object.
    # See:
    #   http://railscasts.com/episodes/416-form-objects
    #
    def validate_password
      # Step 1:  Password and Password confirmation match
      pwd1 = params.fetch(:password, nil)
      pwd2 = params.fetch(:password_confirmation, nil)

      if (pwd1.nil? || pwd2.nil? || pwd1.blank?)
        flash[:alert] = 'You need to provide both a password and a confirmation.'
        render :new
        return false
      end

      if not pwd1 == pwd2
        flash[:alert] = 'The password did not match the confirmation.'
        render :new
        return false
      end

      @password = pwd1
      return true
    end
  end
end
