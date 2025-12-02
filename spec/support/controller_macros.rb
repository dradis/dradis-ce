module ControllerMacros
  extend ActiveSupport::Concern

  included { fixtures :configurations }

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

    # Bypassing the setup Wizard
    ## Password: via fixture file
    ## Analytics: via fixture file
    ## Kit: weaksauce alert: this creates a Node which flags the Setup as done.
    @project.issue_library
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
