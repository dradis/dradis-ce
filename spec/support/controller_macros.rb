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
      # When visiting a form we've already entered data into we will get the
      # cached data prompt. We won't always, and we can't check for it. So we have
      # to try and close the prompt every time and rescue if it errors.
      begin
        page.driver.browser.switch_to.alert
        page.dismiss_prompt
      rescue
      end

      page.execute_script File.read("#{Rails.root}/spec/support/selenium/disable_animations.js")
    end
  end
end
