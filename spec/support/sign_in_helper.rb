module SignInHelper
  def sign_in
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
end

RSpec.configure do |c|
  c.include SignInHelper, type: :feature
end
