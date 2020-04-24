require 'rails_helper'

feature 'Issue edit page server auto save', js: true, feature: true do
  subject { page }

  let(:current_project) { Project.new }
  let(:issue) { create(:issue, node: current_project.issue_library, updated_at: 2.seconds.ago) }
  let(:new_content) { "#[Description]#\r\nNew info" }
  let(:user) { create(:user, :author, password_hash: ::BCrypt::Password.create(password)) }
  let(:password) { 'rspec_pass' }

  let(:login) do
    visit login_path
    fill_in 'login', with: user.email
    fill_in 'password', with: password
    click_button 'Let me in!'
  end

  before do
    create(:configuration, name: 'admin:password', value: ::BCrypt::Password.create(password))

    login
    visit edit_project_issue_path(current_project, issue)
    click_link 'Source'
  end

  it 'updates the resource' do
    fill_in :issue_text, with: new_content
    wait_for_js_events
    
    visit project_issue_path(current_project, issue)

    expect(page).to have_content('New info')
    expect(issue.reload.text).to eq new_content
  end

  it 'creates an autosave activity' do
    expect do
      fill_in :issue_text, with: new_content
      wait_for_js_events
    end.to change { enqueued_activity_tracking_jobs.size }.by(1)
  end

  context 'with papertrail active' do
    before do
      PaperTrail.enabled = true
    end

    it 'creates a papertrail version' do
      expect do
        fill_in :issue_text, with: new_content
        wait_for_js_events
      end.to change { PaperTrail::Version.all.count }.by(1)
    end

    it 'creates a version with an auto-save event' do
      fill_in :issue_text, with: new_content
      wait_for_js_events

      revision = issue.versions.last
      expect(revision.event).to eq 'auto-save'
    end
  end

  # we need to filter by job class because a NotificationsReaderJob
  # will also be enqueued
  def enqueued_activity_tracking_jobs
    ActiveJob::Base.queue_adapter.enqueued_jobs.select do |hash|
      hash[:job] == ActivityTrackingJob
    end
  end

  # Wait for js events to finish. We know events have fired once preview had
  # reloaded with the new content.
  def wait_for_js_events
    find('.textile-preview', text: 'New info', wait: 1)
  end
end
