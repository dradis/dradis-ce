require "spec_helper"

describe "User searches" do
  it "can access search on main navigation" do
    login_as_user

    within ".navbar-inner" do
      expect(page).to have_css "#search_tag"
      expect(page).to have_css "#search_btn"
    end
  end
end

def login_as_user
  configuration = create(:configuration, name: "admin:password",
                         value: BCrypt::Password.create("share_password"))
  visit root_path
  fill_login_form(password: configuration.value)
end

def fill_login_form(password:)
  fill_in "login", with: "test@example.com"
  fill_in "password", with: password
  click_on "Let me in!"
end

