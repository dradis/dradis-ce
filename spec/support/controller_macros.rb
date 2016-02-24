module ControllerMacros
  extend ActiveSupport::Concern

  included { fixtures :configurations }

  # Macro to emulate user login
  def login_as_user(user=create(:user))
    allow_any_instance_of(ApplicationController).to \
      receive(:authenticated?).and_return(true)
    allow_any_instance_of(ApplicationController).to \
      receive(:current_user).and_return(user)
    @logged_in_as = user
  end

  def login_as_admin
    admin = create(:user, :admin)
    login_as_user(admin)
  end

  def login_to_project_as_user
    login_as_user
    @project = build(:project)
    @project.authors << @logged_in_as
    @project.save!
    visit use_project_path(@project)
  end
end
