require "spec_helper"

describe "User searches" do
  it "can access search on main navigation" do
    login_as_user

    within ".navbar" do
      expect(page).to have_css "#q"
      expect(page).to have_css "#search_btn"
    end
  end

  it "when click on search button search results form is shown" do
    login_as_user

    fill_in "q", with: "test"
    click_on "search_btn"

    expect(page.current_path).to eq searches_path
    expect(page).to have_content "Search results"
  end
end

def login_as_user
  password = "shared_password"
  create(:configuration, name: "admin:password",
         value: BCrypt::Password.create(password))
  visit root_path
  fill_login_form(password: password)
end

def fill_login_form(password:)
  fill_in "login", with: "test@example.com"
  fill_in "password", with: password
  click_on "Let me in!"
end

