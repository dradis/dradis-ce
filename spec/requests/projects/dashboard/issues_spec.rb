require 'rails_helper'

describe 'Projects::Dashboard::Issues', type: :request do
  before { login_to_project_as_user }

  describe 'GET /projects/:project_id/dashboard/issues' do
    it 'renders the issues grouped by tag without a grouping selector' do
      tag = create(:tag, name: '!000001_sqli', project: current_project)
      issue = create(:issue, node: current_project.issue_library)
      issue.tags << tag

      get project_dashboard_issues_path(current_project)

      expect(response.body).to include(tag.display_name, issue.title, 'data-groups=')
      expect(response.body).not_to include('name="grouping"')
    end

    context 'with several groupings' do
      let(:other_grouping) do
        value = double(display_name: 'Mine', color: '#112233', tagged?: true)
        Projects::Dashboard::Issues::Grouping.new(key: 'other', label: 'Other', values: [value])
      end

      before do
        allow(Projects::Dashboard::Issues::Grouping).to receive(:available).and_wrap_original do |original, project|
          original.call(project) + [other_grouping]
        end
      end

      it 'renders the selector and groups by the requested grouping' do
        issue = create(:issue, node: current_project.issue_library)

        get project_dashboard_issues_path(current_project, grouping: 'other')

        expect(response.body).to include('<option selected="selected" value="other">Other</option>')
        expect(response.body).to include('Mine', issue.title)
      end
    end
  end
end
