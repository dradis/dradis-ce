require 'rails_helper'

describe 'node pages' do
  describe '#show notes table toolbar', js: true do
    subject { page }

    let(:node) { create(:node) }
    let(:items) {
      notes = []
      (Note::MAX_DELETED_INLINE + 1).times do |i|
        notes << create(:note, node: node, text: "#[Title]#\r\ntest#{i}\r\n\r\n#[Description]#\r\nnote#{i}\r\n")
      end
      notes
    }

    before do
      login_to_project_as_user
      items
      visit node_path(node, tab: 'notes-tab')
    end

    it_behaves_like 'an index table toolbar'
  end
end
