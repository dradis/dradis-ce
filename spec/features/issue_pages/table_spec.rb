require 'rails_helper'

describe 'issue pages' do
  describe '#index table', js: true do
    subject { page }

    before do
      login_to_project_as_user

      @issue1 = create(
        :issue,
        text: "#[Title]#\nIssue1\n\n#[Risk]#\nHigh\n\n#[Description]#\nn/a",
        node: current_project.issue_library
      )

      @issue2 = create(
        :issue,
        text: "#[Title]#\nIssue2\n\n#[Risk]#\nLow\n\n#[Description]#\nn/a",
        node: current_project.issue_library
      )

      visit project_issues_path(current_project)
    end

    let(:columns) { ['Title', 'Created', 'Created by', 'Updated'] }
    let(:custom_columns) { ['Description', 'Risk'] }
    let(:filter) { { keyword: 'Issue1', number_of_rows: 1 } }

    it_behaves_like 'a DataTable'
  end
end
