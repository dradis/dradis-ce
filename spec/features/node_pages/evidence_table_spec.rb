require 'rails_helper'

describe 'node pages' do
  describe '#show evidence table' do
    subject { page }

    before do
      login_to_project_as_user

      node = create(:node)
      @evidence = create(:evidence, node: node, content: "#[Title]#\nEvidence1\n\n#[Description]#\nn/a\n#[Extra]#\nExtra field")
      visit node_path(node, tab: 'evidence-tab')
    end

    let(:columns) { ['Title', 'Created', 'Created by', 'Updated'] }
    let(:custom_columns) { ['Description', 'Extra'] }
    it_behaves_like 'an index table'
  end
end
