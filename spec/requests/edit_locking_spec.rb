require 'rails_helper'

describe 'EditLockable concern' do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:project) { Project.new }
  let(:issue) { create(:issue, node: project.issue_library) }

  before { @project = project }

  describe '#check_edit_lock' do
    context 'when another user has an active editing session' do
      before do
        create(:editing_session,
          user: user_a,
          record_type: 'Issue',
          record_id: issue.id
        )
      end

      it 'renders the lockout page' do
        login_as_user(user_b)
        get edit_project_issue_path(project, issue)
        expect(response.body).to include('currently being edited')
      end

      it 'does not create a session for the locked-out user' do
        login_as_user(user_b)
        get edit_project_issue_path(project, issue)
        expect(EditingSession.where(user: user_b)).to be_empty
      end
    end

    context 'when no other user is editing' do
      it 'renders the edit page' do
        login_as_user(user_a)
        get edit_project_issue_path(project, issue)
        expect(response.body).to include('Edit issue')
      end

      it 'creates an editing session' do
        login_as_user(user_a)
        get edit_project_issue_path(project, issue)
        expect(EditingSession.for_record(issue).where(user: user_a)).to exist
      end
    end

    context 'when force=true' do
      before do
        create(:editing_session,
          user: user_a,
          record_type: 'Issue',
          record_id: issue.id
        )
      end

      it 'bypasses the lock and renders the edit page' do
        login_as_user(user_b)
        get edit_project_issue_path(project, issue, force: 'true')
        expect(response.body).to include('Edit issue')
      end

      it 'creates a session for the bypassing user' do
        login_as_user(user_b)
        get edit_project_issue_path(project, issue, force: 'true')
        expect(EditingSession.for_record(issue).where(user: user_b)).to exist
      end
    end
  end

  describe '#release_edit_session' do
    it 'destroys the editing session on update' do
      login_as_user(user_a)
      create(:editing_session,
        user: user_a,
        record_type: 'Issue',
        record_id: issue.id
      )

      patch project_issue_path(project, issue),
        params: { issue: { text: '#[Title]#\nUpdated' } }

      expect(EditingSession.for_record(issue).where(user: user_a)).not_to exist
    end

    it 'keeps the editing session when the update fails validation' do
      login_as_user(user_a)
      create(:editing_session,
        user: user_a,
        record_type: 'Issue',
        record_id: issue.id
      )

      patch project_issue_path(project, issue),
        params: { issue: { text: 'a' * (DB_MAX_TEXT_LENGTH + 1) } }

      expect(response.body).to include('Edit issue')
      expect(EditingSession.for_record(issue).where(user: user_a)).to exist
    end
  end
end
