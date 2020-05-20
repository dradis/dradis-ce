require 'rails_helper'

describe 'Sessions' do
  subject { page }

  before do
    create(
      :configuration,
      name: 'admin:password',
      value: ::BCrypt::Password.create('rspec_pass')
    )
    @user = create(
      :user,
      :author,
      password_hash: ::BCrypt::Password.create('rspec_pass')
    )
  end

  let(:password) { 'rspec_pass' }

  let(:login) do
    visit login_path
    fill_in 'login', with: @user.email
    fill_in 'password', with: password
    click_button 'Let me in!'
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

    describe 'return after timeout' do
      let(:submit_login_details) do
        fill_in 'login', with: @user.email
        fill_in 'password', with: password
        click_button 'Let me in!'
      end

      it 'redirects to previous page' do
        login

        Timecop.freeze(Time.now + 1.hour) do
          visit new_project_issue_path(Project.find(1))
          submit_login_details
          expect(current_path).to eq(new_project_issue_path(Project.find(1)))
        end
      end

      context 'when editing editor after timeout', js: true do
        it 'redirects to editor path instead of /textile' do
          login
          visit new_project_issue_path(Project.find(1))
          click_link 'Source'

          Timecop.freeze(Time.now + 1.hour) do
            fill_in :issue_text, with: 'Issue Text'
            submit_login_details
            expect(current_path).to eq(new_project_issue_path(Project.find(1)))
          end
        end
      end
    end
  end

  context 'when the user is deleted' do
    it 'forces a logout' do
      login

      @user.destroy
      visit project_path(Project.find(1))

      expect(current_path).to eq(login_path)
      expect(page).to have_content('Access denied')
    end
  end
end
