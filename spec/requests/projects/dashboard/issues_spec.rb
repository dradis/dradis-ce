require 'rails_helper'

describe 'Projects::Dashboard::Issues' do
  before { login_to_project_as_user }

  describe 'GET #index' do
    it 'groups issues by tag' do
      tag = create(:tag)
      issue = create(:issue, node: current_project.issue_library)
      issue.tags << tag

      get project_dashboard_issues_path(current_project)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(tag.display_name)
    end

    it 'renders the empty state when there are no issues' do
      get project_dashboard_issues_path(current_project)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Use issues to represent vulnerabilities or findings.')
    end
  end
end
