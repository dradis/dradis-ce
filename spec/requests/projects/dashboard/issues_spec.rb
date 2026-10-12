require 'rails_helper'

describe 'Projects::Dashboard::Issues', type: :request do
  before { login_to_project_as_user }

  describe 'GET /projects/:project_id/dashboard/issues' do
    it 'renders tagged issues' do
      tag = create(:tag, name: '!000001_sqli', project: current_project)
      issue = create(:issue, node: current_project.issue_library)
      issue.tags << tag

      get project_dashboard_issues_path(current_project)

      expect(response.body).to include(tag.display_name)
      expect(response.body).to include(issue.title)
    end

    it 'renders the groups as chart data' do
      tag = create(:tag, name: '!000001_sqli', project: current_project)
      create(:issue, node: current_project.issue_library).tags << tag

      get project_dashboard_issues_path(current_project)

      expect(response.body).to include('data-groups=')
      expect(response.body).to include('&quot;unassigned&quot;:true')
    end

    it 'does not render the grouping selector when there is only one grouping' do
      get project_dashboard_issues_path(current_project)

      expect(response.body).not_to include('name="grouping"')
    end

    context 'with several groupings' do
      let(:other_grouping) do
        Class.new(Projects::Dashboard::Issues::Grouping) do
          def key = 'other'
          def label = 'Other'
          def values = [OpenStruct.new(display_name: 'Mine', color: '#112233')]
          def matches?(_value, _issue) = true
        end
      end

      before do
        allow(Projects::Dashboard::Issues::Grouping).to receive(:available).and_wrap_original do |original, project|
          original.call(project) + [other_grouping.new(project)]
        end
      end

      it 'renders the grouping selector' do
        get project_dashboard_issues_path(current_project)

        expect(response.body).to include('name="grouping"')
        expect(response.body).to include('<option selected="selected" value="tags">Tags</option>')
        expect(response.body).to include('<option value="other">Other</option>')
      end

      it 'groups by the requested grouping' do
        issue = create(:issue, node: current_project.issue_library)

        get project_dashboard_issues_path(current_project, grouping: 'other')

        expect(response.body).to include('<option selected="selected" value="other">Other</option>')
        expect(response.body).to include('Mine')
        expect(response.body).to include(issue.title)
      end

      it 'falls back to the first grouping when the requested one is unknown' do
        get project_dashboard_issues_path(current_project, grouping: 'bogus')

        expect(response.body).to include('<option selected="selected" value="tags">Tags</option>')
      end
    end

    it 'renders the empty state without issues' do
      get project_dashboard_issues_path(current_project)

      expect(response.body).to include('Use issues to represent vulnerabilities or findings.')
    end
  end
end
