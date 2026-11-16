require 'rails_helper'

describe 'Projects::Dashboard::Issues', type: :request do
  before do
    login_as_user
    @project = create(:project)
    @project.assign_owner(@logged_in_as)
  end

  it 'renders tag groups without a selector, keeping empty groups in the chart only' do
    tag = create(:tag, name: '!000001_sqli', project: current_project)
    empty = create(:tag, name: '!000002_empty', project: current_project)
    issue = create(:issue, node: current_project.issue_library)
    issue.tags << tag

    get project_dashboard_issues_path(current_project)

    html = Nokogiri::HTML(response.body)
    groups = JSON.parse(html.at_css('[data-issues-summary-target="chart"]')['data-groups'])
    expect(groups.find { |group| group['name'] == empty.display_name }['count']).to eq 0
    expect(html.css('[data-issues-summary-target="group"]').text).to include(tag.display_name, issue.title)
    expect(html.css('[data-issues-summary-target="group"]').text).not_to include(empty.display_name)
    expect(html.at_css('[name="grouping"]')).to be_nil
  end

  it 'renders the empty state without issues' do
    get project_dashboard_issues_path(current_project)

    expect(response.body).to include('Use issues to represent vulnerabilities or findings.')
  end

  context 'with an additional grouping strategy' do
    let(:group) do
      Projects::Dashboard::Issues::Group.new(key: 'custom', name: 'Custom', color: '#112233', issues: [])
    end
    let(:strategy) { double(key: 'other', label: 'Other', groups: [group]) }

    before do
      allow(Projects::Dashboard::Issues::Grouping).to receive(:available).and_wrap_original do |original, project|
        original.call(project) + [strategy]
      end
    end

    it 'selects the requested strategy' do
      issue = create(:issue, node: current_project.issue_library)
      group.issues << issue

      get project_dashboard_issues_path(current_project, grouping: 'other')

      expect(response.body).to include('<option selected="selected" value="other">Other</option>')
      expect(response.body).to include('Custom', issue.title)
    end

    it 'falls back to tags when a grouping is no longer available' do
      get project_dashboard_issues_path(current_project, grouping: 'removed')

      expect(response.body).to include('<option selected="selected" value="tags">Tags</option>')
    end
  end
end
