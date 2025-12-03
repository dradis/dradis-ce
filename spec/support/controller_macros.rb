module ControllerMacros
  extend ActiveSupport::Concern

  included do
    # Bypassing the setup Wizard
    ## Shared Password
    ## Analytics
    fixtures :configurations
    ## Kit
    fixtures :nodes
  end

  # Macro to emulate user login
  def login_as_user(user = create(:user))
    allow_any_instance_of(ApplicationController).to \
      receive(:authenticated?).and_return(true)
    allow_any_instance_of(ApplicationController).to \
      receive(:current_user).and_return(user)
    @logged_in_as = user
  end

  def login_to_project_as_user
    login_as_user

    @project = Project.new
  end

  def current_project
    @project
  end

  def visit(arg)
    page.visit(arg)

    if RSpec.current_example.metadata[:js]
      page.execute_script File.read("#{Rails.root}/spec/support/selenium/disable_animations.js")
    end
  end
end
