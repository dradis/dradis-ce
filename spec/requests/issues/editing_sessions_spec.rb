require 'rails_helper'

describe 'Issue editing sessions' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: current_project.issue_library) }

  describe 'DELETE /projects/:project_id/issues/:issue_id/editing_session' do
    it 'releases the lock held by the current user' do
      issue.acquire_edit_session(@logged_in_as)

      delete project_issue_editing_session_path(current_project, issue)

      expect(response).to have_http_status(:no_content)
      expect(EditingSession.for_record(issue)).to be_nil
    end

    it 'leaves a lock held by another user in place' do
      issue.acquire_edit_session(create(:user))

      delete project_issue_editing_session_path(current_project, issue)

      expect(response).to have_http_status(:no_content)
      expect(EditingSession.for_record(issue)).to be_present
    end
  end
end
