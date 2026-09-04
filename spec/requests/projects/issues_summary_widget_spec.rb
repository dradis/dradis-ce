require 'rails_helper'

describe 'Projects', type: :request do
  before { login_to_project_as_user }

  describe 'GET /projects/:id' do
    context 'with tagged issues' do
      it 'renders the issues so far widget with chart and tag accordion' do
        tag = create(:tag, name: '!000001_sqli')
        issue = create(:issue, node: current_project.issue_library)
        issue.tags << tag

        get project_path(current_project)

        expect(response.body).to include('Issues so far')
        expect(response.body).to include(tag.display_name)
        expect(response.body).to include(issue.title)
      end
    end

    context 'without issues' do
      it 'renders the empty state' do
        get project_path(current_project)

        expect(response.body).to include('Use issues to represent vulnerabilities or findings.')
      end
    end
  end
end
