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
      let(:project) { Project.find(1) }

      let(:submit_login_details) do
        fill_in 'login', with: @user.email
        fill_in 'password', with: password
        click_button 'Let me in!'
      end

      before do
        login
      end

      it 'redirects to previous page' do
        Timecop.freeze(Time.now + 1.hour) do
          visit new_project_issue_path(project)
          submit_login_details
          expect(current_path).to eq(new_project_issue_path(project))
        end
      end

      context 'when typing in editor after timeout', js: true do
        before do
          visit new_project_issue_path(project)
        end

        it 'redirects to same editor form when typing in Fields view' do
          click_link 'Fields'

          Timecop.freeze(Time.now + 1.hour) do
            fill_in :item_form_field_name_0, with: 'Issue Text'
            sleep 1 # Have to sleep due to ajax request
            expect(current_path).to eq login_path
            submit_login_details
            expect(current_path).to eq(new_project_issue_path(project))
          end
        end

        it 'redirects to same editor form when typing in Source view' do
          click_link 'Source'

          Timecop.freeze(Time.now + 1.hour) do
            fill_in :issue_text, with: 'Issue Text'
            sleep 1 # Have to sleep due to ajax request
            expect(current_path).to eq login_path
            submit_login_details
            expect(current_path).to eq(new_project_issue_path(project))
          end
        end
      end

      context 'when creating evidence in issue page', js: true do
        let(:issue) { create(:issue, node: project.issue_library) }
        let(:node) { create(:node, project: project) }


        it 'redirects to issue show page' do
          visit project_issue_path(project, issue)

          within '.tabs-container' do
            click_link 'Evidence 0'
          end

          within '#evidence-tab' do
            find('.js-add-evidence').click
          end

          Timecop.freeze(Time.now + 1.hour) do
            click_button 'Save Evidence'
            expect(current_path).to eq login_path
            submit_login_details
            expect(current_path).to eq(project_issue_path(project, issue))
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
