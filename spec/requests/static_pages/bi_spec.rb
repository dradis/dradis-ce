require 'rails_helper'

describe 'BI insights' do
  before { login_to_project_as_user }

  let(:current_year_start) { Time.current.beginning_of_year }
  let(:last_year_start) { 1.year.ago.beginning_of_year }
  let(:last_year_end) { 1.year.ago }

  def issue_text(title)
    "#[Title]#\n#{title}\n\n#[Description]#\nFoo"
  end

  describe 'GET /projects/1/addons/bi/insights/issues' do
    it 'returns successfully with no data' do
      get static_bi_insights_issues_path
      expect(response).to be_successful
    end

    it 'counts issues created this year only' do
      create(:issue, text: issue_text('Current'), created_at: current_year_start + 1.day)
      create(:issue, text: issue_text('Current'), created_at: current_year_start + 2.days)
      create(:issue, text: issue_text('Old'), created_at: 2.years.ago)
      get static_bi_insights_issues_path
      expect(response.body).to match(/<h4 class="mb-0">2<\/h4>/)
    end

    context 'when filtering by a valid tag' do
      let(:tag) { create(:tag, name: '!ff0000_critical') }
      let!(:tagged_issue) do
        issue = create(:issue, text: issue_text('Tagged'), created_at: current_year_start + 1.day)
        issue.tags << tag
        issue
      end
      let!(:untagged_issue) { create(:issue, text: issue_text('Untagged'), created_at: current_year_start + 1.day) }

      it 'returns only issues with that tag' do
        get static_bi_insights_issues_path, params: { tag: '!ff0000_critical' }
        expect(response).to be_successful
        expect(response.body).to match(/<h4 class="mb-0">1<\/h4>/)
      end
    end

    context 'when filtering by a nonexistent tag' do
      let!(:issue) { create(:issue, created_at: current_year_start + 1.day) }

      it 'ignores the filter and returns all issues' do
        get static_bi_insights_issues_path, params: { tag: 'nonexistent' }
        expect(response).to be_successful
        expect(response.body).to match(/<h4 class="mb-0">1<\/h4>/)
      end
    end
  end

  describe 'GET /projects/1/addons/bi/insights/top-issues' do
    it 'returns successfully with no data' do
      get static_bi_insights_top_issues_path
      expect(response).to be_successful
    end

    it 'groups issues by title and orders by count descending' do
      3.times { create(:issue, text: issue_text('SQL Injection'), created_at: current_year_start + 1.day) }
      1.times { create(:issue, text: issue_text('XSS'), created_at: current_year_start + 1.day) }
      get static_bi_insights_top_issues_path
      expect(response.body).to match(/SQL Injection.*XSS/m)
    end

    it 'excludes issues from previous years' do
      create(:issue, text: issue_text('Old Issue'), created_at: 2.years.ago)
      get static_bi_insights_top_issues_path
      expect(response.body).not_to include('Old Issue')
    end

    it 'limits results to 10' do
      11.times { |i| create(:issue, text: issue_text("Issue #{i}"), created_at: current_year_start + 1.day) }
      get static_bi_insights_top_issues_path
      expect(response.body.scan('issue-title').size).to eq(10)
    end

    context 'when filtering by a nonexistent tag' do
      it 'ignores the filter and returns successfully' do
        get static_bi_insights_top_issues_path, params: { tag: 'nonexistent' }
        expect(response).to be_successful
      end
    end
  end

  describe 'yoy_delta calculation' do
    context 'when there were no issues last year' do
      it 'returns 100% when there are issues this year' do
        create(:issue, created_at: current_year_start + 1.day)
        get static_bi_insights_issues_path
        expect(response.body).to include('100')
      end

      it 'returns 0% when there are no issues this year either' do
        get static_bi_insights_issues_path
        expect(response.body).to match(/fa-arrows-up-down.*0%/m)
      end
    end

    context 'when there were issues last year' do
      before do
        2.times { create(:issue, created_at: last_year_start + 1.day) }
        4.times { create(:issue, created_at: current_year_start + 1.day) }
      end

      it 'calculates the percentage change correctly' do
        get static_bi_insights_issues_path
        expect(response.body).to include('100')
      end
    end
  end
end
