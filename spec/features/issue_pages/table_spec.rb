require 'rails_helper'

describe 'issue pages' do
  describe '#index table', js: true do
    subject { page }

    before do
      login_to_project_as_user

      @issue = create(
        :issue,
        text: "#[Title]#\nIssue1\n\n#[Risk]#\nHigh\n\n#[Description]#\nn/a",
        node: current_project.issue_library
      )

      create(:issue, node: current_project.issue_library)

      @tags = Tag::DEFAULT_TAGS.map do |tag|
        if defined?(Dradis::Pro)
          create(:tag, name: tag, project: current_project)
        else
          create(:tag, name: tag)
        end
      end

      visit project_issues_path(current_project)
    end

    let(:default_columns) { ['Title', 'Created', 'Updated'] }
    let(:hidden_columns) { ['Description', 'Risk'] }
    let(:filter) { { keyword: @issue.title, filter_count: 1 } }

    it_behaves_like 'a DataTable'

    let(:new_content) { "#[Title]#\nNew Title\n\n#[Risk]#\nHigh\n\n#[Description]#\nn/a\n\n#[New Field]#\nNew Field Value" }
    let(:old_content) { "#[Title]#\nIssue1\n\n#[Risk]#\nHigh\n\n#[Description]#\nn/a" }
    let(:resource) { @issue }
    let(:content_attribute) { :text }

    it_behaves_like 'a DataTable with Dynamic Columns'
  end
end
