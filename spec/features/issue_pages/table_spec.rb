require 'rails_helper'

describe 'issue pages' do
  describe '#index table' do
    subject { page }

    before do
      login_to_project_as_user

      @issue = create(
        :issue,
        content: "#[Title]#\nIssue1\n\n#[Risk]#\nHigh\n\n#[Description]#\nn/a",
        node: current_project.issue_library

      )
      visit project_issues_path(current_project)
    end

    let(:columns) { ['Title', 'Created', 'Created by', 'Updated'] }
    let(:custom_columns) { ['Description', 'Risk'] }
    it_behaves_like 'an index table'
  end
end
