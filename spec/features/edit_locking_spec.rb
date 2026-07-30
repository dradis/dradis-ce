require 'rails_helper'

describe 'Edit locking multi-actor flow' do
  let(:project) { Project.new }
  let(:issue) { create(:issue, node: project.issue_library) }
  let(:password) { 'spec-password' }

  before do
    Configuration.find_or_create_by(name: 'admin:password')
      .update!(value: BCrypt::Password.create(password))
  end

  def sign_in_as(username)
    visit login_path
    fill_in 'Username', with: username
    fill_in 'Password', with: password
    click_button 'Log in'
  end

  it 'locks the record for a second editor, lets them bypass it, and releases the lock on save' do
    Capybara.using_session(:user_a) { sign_in_as('user-a@example.com') }
    Capybara.using_session(:user_b) { sign_in_as('user-b@example.com') }

    Capybara.using_session(:user_a) do
      visit edit_project_issue_path(project, issue)
      expect(page).to have_content('Edit issue')
    end

    Capybara.using_session(:user_b) do
      visit edit_project_issue_path(project, issue)
      expect(page).to have_content('currently being edited')
      expect(page).to have_content('user-a@example.com')

      click_link 'Go back'
      expect(page).not_to have_content('currently being edited')
    end

    Capybara.using_session(:user_b) do
      visit edit_project_issue_path(project, issue)
      click_link 'Edit anyway'
      expect(page).to have_content('Edit issue')
    end

    Capybara.using_session(:user_a) do
      find('.btn-states button[type="submit"]').click
      expect(page).to have_content('Issue updated.')
    end

    user_a = User.find_by(email: 'user-a@example.com')
    expect(EditingSession.for_record(issue).where(user: user_a)).not_to exist
  end

  it 'releases the lock when the editor clicks cancel', js: true do
    Capybara.using_session(:user_a) { sign_in_as('user-a@example.com') }

    Capybara.using_session(:user_a) do
      visit edit_project_issue_path(project, issue)
      expect(page).to have_content('Edit issue')

      click_link 'Cancel'
      expect(page).to have_current_path(project_issue_path(project, issue))
    end

    user_a = User.find_by(email: 'user-a@example.com')

    # The lock release request is fired with `fetch(..., { keepalive: true })`
    # alongside the Cancel link's navigation, so it may still be in flight
    # once the browser lands on the next page.
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.1 while EditingSession.for_record(issue).where(user: user_a).exists?
    end

    expect(EditingSession.for_record(issue).where(user: user_a)).not_to exist
  end
end
