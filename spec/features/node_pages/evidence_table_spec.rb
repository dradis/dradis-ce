require 'rails_helper'

describe 'node pages' do
  describe '#show evidence table' do
    subject { page }

    before do
      login_to_project_as_user

      node = create(:node, project: @project)
      issue = create(:issue, node: @project.issue_library)
      @evidence = create(
        :evidence,
        node: node,
        content: "#[Title]#\nEvidence1\n\n#[Description]#\nn/a\n#[Extra]#\nExtra field",
        issue: issue,
      )
      visit project_node_path(node.project, node, tab: 'evidence-tab')
    end

    let(:columns) { ['Title', 'Created', 'Created by', 'Updated'] }
    let(:custom_columns) { ['Description', 'Extra'] }
    it_behaves_like 'an index table'
  end
end
