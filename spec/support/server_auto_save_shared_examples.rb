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
      visit edit_polymorphic_path(path_params)
      click_link 'Source'
    end

    it 'updates the resource' do
      find('.editor-field textarea').set new_content
      navigate_away_triggering_autosave

      visit polymorphic_path(path_params)

      expect(page).to have_content('New info')
      expect(autosaveable.reload.send(content_attribute)).to eq new_content
    end

    it 'creates a papertrail version', versioning: true do
      expect do
        find('.editor-field textarea').set new_content
        navigate_away_triggering_autosave
      end.to change { autosaveable.reload.versions.count }.by_at_least(1)
    end

    it 'creates a version with an auto-save event', versioning: true do
      find('.editor-field textarea').set new_content
      navigate_away_triggering_autosave

      revision = autosaveable.versions.last
      expect(revision.event).to eq 'auto-save'
    end

    it 'discards the autosave when Discard Changes is clicked', versioning: true do
      find('.editor-field textarea').set new_content
      navigate_away_triggering_autosave

      expect do
        click_link 'Discard changes'
      end.to change { autosaveable.reload.versions.count }.by_at_least(-2)
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
      navigate_away_triggering_autosave

      visit polymorphic_path(path_params.push(:revisions))
      row = find('.revisions-table table tbody tr.active')

      expect(row).to have_content('Auto-saved', count: 1)
      expect(row).to have_content('Currently Viewing')
    end

    it 'only keeps a single auto-save item in the revision history', versioning: true do
      3.times do
        find('.editor-field textarea').set new_content
        navigate_away_triggering_autosave
      end

      visit polymorphic_path(path_params.push(:revisions))

      expect(page).to have_content('Auto-saved', count: 1)
    end

    it 'removes all auto-saves when updated', versioning: true do
      perform_enqueued_jobs do
        find('.editor-field textarea').set new_content
        navigate_away_triggering_autosave

        within '.form-actions' do
          find('[type="submit"]').click
        end

        visit polymorphic_path(path_params.push(:revisions))

        expect(page).not_to have_content('Auto-saved')

        row = find('.revisions-table table tbody tr.active')
        expect(row).to have_content('Update')
        expect(row).to have_content('Currently Viewing')
      end
    end

    it 'shows entire diff between original and current not just last revision', versioning: true do
      perform_enqueued_jobs do
        old_content = autosaveable.title
        find('.editor-field textarea').set 'intermediary'
        find('.editor-field textarea').set new_content
        navigate_away_triggering_autosave

        within '.form-actions' do
          find('[type="submit"]').click
        end

        visit polymorphic_path(path_params.push(:revisions))

        expect(find('#diff del.differ')).to have_content("#[Title]#\n#{old_content}")
        expect(find('#diff ins.differ')).to have_content("#[Description]#\nNew info")
      end
    end

    it 'removes auto-saves when discarded', versioning: true do
      perform_enqueued_jobs do
        # Create an update revision otherwise we won't have access to the
        # revisions page
        find('.editor-field textarea').set new_content
        navigate_away_triggering_autosave

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

    it 'credits the author of the update', versioning: true do
      perform_enqueued_jobs do
        find('.editor-field textarea').set new_content
        navigate_away_triggering_autosave

        # Login another user to perform the update
        user = create(:user)
        login_as_user user

        visit edit_polymorphic_path(path_params)

        within '.form-actions' do
          find('[type="submit"]').click
        end

        visit polymorphic_path(path_params.push(:revisions))
        row = find('.revisions-table table tbody tr.active')
        expect(row).to have_content('Update')
        expect(row).to have_content('Currently Viewing')
        expect(row).to have_content(user.email)
      end
    end
  end
end

# Navigate away from the edit screen to trigger autosave then navigate back
def navigate_away_triggering_autosave
  visit polymorphic_path(path_params)
  visit edit_polymorphic_path(path_params)
  click_link 'Source'
end

def content_attribute
  case autosaveable
  when Card; 'description'
  when Issue, Note; 'text' # FIXME - ISSUE/NOTE INHERITANCE
  when Evidence; 'content'
  end
end
