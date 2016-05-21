module ControllerMacros
  extend ActiveSupport::Concern

  included { fixtures :configurations }

  # Macro to emulate user login
  # FIXME: User singleton
  # def login_as_user(user=create(:user))
  def login_as_user(user=create(:user))
    allow_any_instance_of(ApplicationController).to \
      receive(:authenticated?).and_return(true)
    allow_any_instance_of(ApplicationController).to \
      receive(:current_user).and_return(user)
    @logged_in_as = user
  end

  def login_to_project_as_user
    login_as_user
    @project    = OpenStruct.new
    @project.id = 1
  end
end
