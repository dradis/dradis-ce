require 'rails_helper'

describe 'node pages' do
  describe '#show evidence table toolbar', js: true do
    subject { page }

    let(:node) { create(:node, project: @project) }
    let(:items) {
      evidence = []
      (::Configuration.max_deleted_inline + 1).times do |i|
        evidence << create(
          :evidence,
          content: "#[Title]#\r\ntest#{i}\r\n\r\n#[Description]#\r\nevidence#{i}\r\n",
          # Each evidence needs to be for a different issue so we can filter by
          # issue title in 'an index table toolbar' shared examples:
          issue: create(:issue, node: current_project.issue_library),
          node: node,
        )
      end
      evidence
    }

    before do
      login_to_project_as_user
      items
      visit project_node_path(@project, node, tab: 'evidence-tab')
    end

    it_behaves_like 'an index table toolbar'
  end
end
