shared_examples 'an editor with server side auto-save' do
  context js: true do
    let(:current_project) { Project.new }
    let(:new_content) { "#[Description]#\r\nNew info" }
    let(:password) { 'rspec_pass' }
    let(:user) { create(:user, :author, password_hash: ::BCrypt::Password.create(password)) }

    # We actually have to login without faking the session, otherwise a warden
    # session won't exist for action cable to pickup.
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

    it 'creates a papertrail version', versioning: true do
      expect do
        find('.editor-field textarea').set new_content
        wait_for_js_events
      end.to change { autosaveable.versions.count }.by_at_least(1)
      # Evidence specs do something weird where it looks like an edit is being
      # triggered on load.
    end

    it 'creates a version with an auto-save event', versioning: true do
      find('.editor-field textarea').set new_content
      wait_for_js_events

      revision = autosaveable.versions.last
      expect(revision.event).to eq 'auto-save'
    end

    it 'discards the autosave when Discard Changes is clicked', versioning: true do
      find('.editor-field textarea').set new_content
      wait_for_js_events

      expect do
        click_link 'Discard changes'
      end.to change { autosaveable.versions.count }.by(-1)
    end
  end
end

shared_examples 'a record with auto-save revisions' do
  context js: true do
    let(:current_project) { Project.new }
    let(:new_content) { "#[Description]#\r\nNew info" }
    let(:password) { 'rspec_pass' }
    let(:user) { create(:user, :author, password_hash: ::BCrypt::Password.create(password)) }

    # We actually have to login without faking the session, otherwise a warden
    # session won't exist for action cable to pickup.
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

    it 'creates a single auto-save item in the revision history', versioning: true do
      find('.editor-field textarea').set new_content
      wait_for_js_events

      visit polymorphic_path(path_params.push(:revisions))
      row = find('.revisions-table table tbody tr.active')

      expect(row).to have_content('Auto-saved', count: 1)
      expect(row).to have_content('Currently Viewing')
    end

    it 'only keeps a single auto-save item in the revision history', versioning: true do
      3.times do
        find('.editor-field textarea').set new_content
        wait_for_js_events
      end

      visit polymorphic_path(path_params.push(:revisions))

      expect(page).to have_content('Auto-saved', count: 1)
    end

    it 'removes all auto-saves when updated', versioning: true do
      find('.editor-field textarea').set new_content
      wait_for_js_events

      within '.form-actions' do
        find('[type="submit"]').click
      end

      visit polymorphic_path(path_params.push(:revisions))

      expect(page).not_to have_content('Auto-saved')

      row = find('.revisions-table table tbody tr.active')
      expect(row).to have_content('Update')
      expect(row).to have_content('Currently Viewing')
    end

    it 'shows entire diff between original and current not just last revision', versioning: true do
      old_content = autosaveable.title
      find('.editor-field textarea').set 'intermediary'
      find('.editor-field textarea').set new_content
      wait_for_js_events

      within '.form-actions' do
        find('[type="submit"]').click
      end

      visit polymorphic_path(path_params.push(:revisions))

      expect(find('#diff del.differ')).to have_content("#[Title]#\n#{old_content}")
      expect(find('#diff ins.differ')).to have_content("#[Description]#\nNew info")
    end

    it 'removes auto-saves when discarded', versioning: true do
      # Create an update revision otherwise we won't have access to the
      # revisions page
      find('.editor-field textarea').set new_content
      wait_for_js_events

      within '.form-actions' do
        find('[type="submit"]').click
      end

      visit polymorphic_path(path_params, action: :edit)

      find('.editor-field textarea').set 'newer_content'
      click_link 'Discard changes'

      visit polymorphic_path(path_params.push(:revisions))
      expect(page).not_to have_content('Auto-saved')
    end
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
