require 'rails_helper'

describe 'node pages' do
  describe '#show evidence table toolbar', js: true do
    subject { page }

    let(:node) { create(:node) }
    let(:items) {
      evidence = []
      (::Configuration.max_deleted_inline + 1).times do |i|
        evidence << create(:evidence, node: node, content: "#[Title]#\r\ntest#{i}\r\n\r\n#[Description]#\r\nevidence#{i}\r\n")
      end
      evidence
    }

    before do
      login_to_project_as_user
      items
      visit node_path(node, tab: 'evidence-tab')
    end

    it_behaves_like 'an index table toolbar'
  end
end
