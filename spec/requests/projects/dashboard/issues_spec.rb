require 'rails_helper'

describe 'Projects::Dashboard::Issues', type: :request do
  before { login_to_project_as_user }

  describe 'GET /projects/:project_id/dashboard/issues' do
    it 'renders tagged issues' do
      tag = create(:tag, name: '!000001_sqli')
      issue = create(:issue, node: current_project.issue_library)
      issue.tags << tag

      get project_dashboard_issues_path(current_project)

      expect(response.body).to include(tag.display_name)
      expect(response.body).to include(issue.title)
    end

    it 'renders the empty state without issues' do
      get project_dashboard_issues_path(current_project)

      expect(response.body).to include('Use issues to represent vulnerabilities or findings.')
    end
  end
end
