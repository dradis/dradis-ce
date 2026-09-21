# the following must be defined for this to work: record, edit_path, and a
# #submit_form method that saves the currently-open edit form
shared_examples 'a lockable resource' do
  let(:password) { 'spec-password' }

  before do
    Configuration.find_or_create_by(name: 'admin:password').update!(value: BCrypt::Password.create(password))
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
      visit edit_path
      expect(page).to have_no_content('currently being edited')
    end

    Capybara.using_session(:user_b) do
      visit edit_path
      expect(page).to have_content('currently being edited')
      expect(page).to have_content('user-a@example.com')

      click_link 'Go back'
      expect(page).to have_no_content('currently being edited')
    end

    Capybara.using_session(:user_b) do
      visit edit_path
      click_link 'Edit anyway'
      expect(page).to have_no_content('currently being edited')
    end

    Capybara.using_session(:user_a) { submit_form }

    expect(EditingSession.for_record(record)).to be_nil
  end

  it 'releases the lock when the editor clicks cancel', js: true do
    Capybara.using_session(:user_a) { sign_in_as('user-a@example.com') }

    Capybara.using_session(:user_a) do
      visit edit_path
      click_link 'Cancel'
    end

    # The lock release request is fired with `fetch(..., { keepalive: true })`
    # alongside the Cancel link's navigation, so it may still be in flight
    # once the browser lands on the next page.
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.1 while EditingSession.for_record(record)
    end

    expect(EditingSession.for_record(record)).to be_nil
  end
end
