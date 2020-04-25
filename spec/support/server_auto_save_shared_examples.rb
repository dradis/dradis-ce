shared_examples 'an editor with server side auto-save' do
  context js: true do
    let(:current_project) { Project.new }
    let(:new_content) { "#[Description]#\r\nNew info" }
    let(:password) { 'rspec_pass' }
    let(:user) { create(:user, :author, password_hash: ::BCrypt::Password.create(password)) }

    let(:login) do
      visit login_path
      fill_in 'login', with: user.email
      fill_in 'password', with: password
      click_button 'Let me in!'
    end

    before do
      create(:configuration, name: 'admin:password', value: ::BCrypt::Password.create(password))

      login
      visit polymorphic_path(path_params, action: :edit)
      click_link 'Source'
    end

    it 'updates the resource' do
      find('.editor-field textarea').set new_content
      wait_for_js_events
      
      visit polymorphic_path(path_params)

      expect(page).to have_content('New info')
      expect(autosaveable.reload.send(content_attribute)).to eq new_content
    end

    it 'creates an autosave activity' do
      expect do
        find('.editor-field textarea').set new_content
        wait_for_js_events
      end.to change { enqueued_activity_tracking_jobs.size }.by(1)
    end

    context 'with papertrail active' do
      before do
        PaperTrail.enabled = true
      end

      it 'creates a papertrail version' do
        require 'pry'
        expect do
          find('.editor-field textarea').set new_content
          wait_for_js_events
        end.to change { PaperTrail::Version.all.count }.by_at_least(1)
        # Evidence specs do something weird where it looks like an edit is being
        # triggered on load.
      end

      it 'creates a version with an auto-save event' do
        find('.editor-field textarea').set new_content
        wait_for_js_events

        revision = autosaveable.versions.last
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

    def content_attribute
      case autosaveable
      when Card; 'description'
      when Issue, Note; 'text' # FIXME - ISSUE/NOTE INHERITANCE
      when Evidence; 'content'
      end
    end
  end
end
