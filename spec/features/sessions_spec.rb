require 'rails_helper'

describe 'Sessions' do
  subject { page }

  # This matches fixtures/configurations.yml value.
  let(:password) { 'rspec_pass' }
  let(:user) do
    create(
      :user,
      :author,
      password_hash: ::BCrypt::Password.create(password)
    )
  end

  # This needs to be a helper and not a let() block, because let is memoized
  # and reused.
  def login
    # This gets us past Setup: Step 2
    project = create(:project)
    project.issue_library

    visit login_path
    fill_in 'login', with: user.email
    fill_in 'password', with: password
    click_button 'Log in'
  end

  context 'when using the correct password' do
    it 'users can log in' do
      login

      expect(current_path).to eq(project_path(Project.find(1)))
    end
  end

  context 'when using an incorrect password' do
    let(:password) { 'wrong_pass'}

    it 'redirect to login with a message' do
      login

      expect(current_path).to eq(login_path)
      expect(page).to have_content('Invalid credentials')
    end
  end

  context 'when session is expired' do
    it 'redirect to login with a message' do
      login

      Timecop.freeze(Time.now + 1.hour) do
        visit project_path(Project.find(1))

        expect(current_path).to eq(login_path)
        expect(page).to have_content('Session timed out!')
      end
    end
  end

  context 'when the user is deleted' do
    it 'forces a logout' do
      login

      user.destroy
      visit projects_path

      expect(current_path).to eq(login_path)
      expect(page).to have_content('Access denied')
    end
  end
end
