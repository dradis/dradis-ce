require 'rails_helper'

describe 'Sessions' do
  subject { page }

  before do
    create(
      :configuration,
      name: 'admin:password',
      value: ::BCrypt::Password.create('rspec_pass')
    )
  end

  let(:password) { 'rspec_pass' }

  let(:login) do
    visit login_path
    fill_in 'login', with: 'rspec_user'
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
  end
end
