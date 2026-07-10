require 'rails_helper'

describe 'Edit locking' do
  subject { page }

  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: current_project.issue_library) }
  let(:other_user) { create(:user) }

  context 'when another user is also editing the record' do
    before do
      create(:editing_session,
        user: other_user,
        record_type: 'Issue',
        record_id: issue.id
      )
    end

    it 'renders the "Also editing" avatar inside the sticky form-actions bar' do
      visit edit_project_issue_path(current_project, issue, force: 'true')

      expect(page).to have_selector('.form-actions.sticky .editing-presence-editors')
      expect(page).not_to have_selector('.btn-group .editing-presence-editors')
    end
  end
end
