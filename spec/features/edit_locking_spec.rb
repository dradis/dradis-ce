require 'rails_helper'

describe 'Edit locking' do
  subject { page }

  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: current_project.issue_library) }
  let(:other_user) { create(:user) }

  context 'when another user is also editing the record' do
    before do
      create(:editing_session,
        user: other_user,
        record_type: 'Issue',
        record_id: issue.id
      )
    end

    it 'renders the "Also editing" avatar inside the sticky form-actions bar' do
      visit edit_project_issue_path(current_project, issue, force: 'true')

      expect(page).to have_selector('.form-actions.sticky .editing-presence-editors')
      expect(page).not_to have_selector('.btn-group .editing-presence-editors')
    end
  end
end

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
      visit edit_project_issue_path(project, issue, force: 'true')
      expect(page).to have_selector(
        '.form-actions.sticky .editing-presence-editors .editing-presence-avatar[title="user-b@example.com"]'
      )
    end

    Capybara.using_session(:user_a) do
      find('.btn-states button[type="submit"]').click
      expect(page).to have_content('Issue updated.')
    end

    user_a = User.find_by(email: 'user-a@example.com')
    expect(EditingSession.for_record(issue).where(user: user_a)).not_to exist
  end
end
