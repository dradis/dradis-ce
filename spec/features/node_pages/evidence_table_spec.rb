require 'rails_helper'

describe 'node pages' do
  describe '#show evidence table' do
    subject { page }

    before do
      login_to_project_as_user

      @node = create(:node, project: @project)
      issue = create(:issue, node: @project.issue_library)
      @evidence = create(
        :evidence,
        node: @node,
        content: "#[Title]#\nEvidence1\n\n#[Description]#\nn/a\n#[Extra]#\nExtra field",
        issue: issue,
      )

      create(:evidence, node: @node, issue: issue)
      visit project_node_path(@project, @node, tab: 'evidence-tab')
    end

    let(:default_columns) { ['Title', 'Label'] }
    let(:hidden_columns) { ['Created', 'Created by', 'Updated'] }
    let(:filter) { { keyword: @evidence.title, filter_count: 1 } }

    it_behaves_like 'a DataTable'

    let(:new_content) { "#[Title]#\nEvidence1\n\n#[Description]#\nn/a\n#[Extra]#\nExtra field\n\n#[New Field]#\nNew Field Value" }
    let(:old_content) { "#[Title]#\nEvidence1\n\n#[Description]#\nn/a\n#[Extra]#\nExtra field" }
    let(:resource) { @evidence }
    let(:content_attribute) { :content }

    it_behaves_like 'a DataTable with Dynamic Columns'
  end
end
