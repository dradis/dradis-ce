require 'rails_helper'

describe 'node pages' do
  describe '#show notes table' do
    subject { page }

    before do
      login_to_project_as_user

      node = create(:node, project: current_project)
      @note = create(:note, node: node, text: "#[Title]#\nNote1\n\n#[Description]#\nn/a\n#[Extra]#\nExtra field")
      create(:note, node: node)

      visit project_node_path(current_project, node, tab: 'notes-tab')
    end

    let(:default_columns) { ['Title', 'Created', 'Updated'] }
    let(:hidden_columns) { ['Description', 'Extra'] }
    let(:filter) { { keyword: @note.title, filter_count: 1 } }

    it_behaves_like 'a DataTable'
  end
end
