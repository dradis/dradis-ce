require 'rails_helper'

describe 'LockableResource concern' do
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

    context 'when another user has a stale editing session' do
      before do
        create(:editing_session,
          user: user_a,
          record_type: 'Issue',
          record_id: issue.id,
          created_at: EditingSession.stale_after.ago - 1.minute
        )
      end

      it 'renders the edit page instead of the lockout page' do
        login_as_user(user_b)
        get edit_project_issue_path(project, issue)
        expect(response.body).to include('Edit issue')
      end

      it 'purges the stale session' do
        login_as_user(user_b)
        get edit_project_issue_path(project, issue)
        expect(EditingSession.where(user: user_a)).not_to exist
      end
    end

    context 'when rendering the lockout page' do
      before do
        create(:editing_session,
          user: user_a,
          record_type: 'Issue',
          record_id: issue.id
        )
      end

      it 'links back to the record instead of following the referer' do
        login_as_user(user_b)
        get edit_project_issue_path(project, issue), headers: { 'HTTP_REFERER' => 'https://evil.example.com/phish' }

        expect(response.body).to include(project_issue_path(project, issue))
        expect(response.body).not_to include('https://evil.example.com/phish')
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

      it 'does not create a new session, leaving the original owner as the lock holder' do
        login_as_user(user_b)
        get edit_project_issue_path(project, issue, force: 'true')

        expect(EditingSession.for_record(issue).count).to eq(1)
        expect(EditingSession.for_record(issue).first.user).to eq(user_a)
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

  describe 'DELETE project_issue_editing_session_path' do
    before do
      create(:editing_session,
        user: user_a,
        record_type: 'Issue',
        record_id: issue.id
      )
    end

    it 'releases the current user\'s editing session' do
      login_as_user(user_a)
      delete project_issue_editing_session_path(project, issue)

      expect(EditingSession.for_record(issue).where(user: user_a)).not_to exist
    end

    it 'does not release another user\'s editing session on a different record' do
      other_issue = create(:issue, node: project.issue_library)
      create(:editing_session, user: user_b, record_type: 'Issue', record_id: other_issue.id)

      login_as_user(user_a)
      delete project_issue_editing_session_path(project, issue)

      expect(EditingSession.for_record(other_issue).where(user: user_b)).to exist
    end
  end
end
