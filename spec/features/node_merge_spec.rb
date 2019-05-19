require 'rails_helper'

describe 'merging a node', js: true do
  subject { page }

  before do
    login_to_project_as_user

    @node_0 = create_node(label: 'Node 0', project: current_project)
    @node_1 = create_node(label: 'Node 1', parent: @node_0)
    @node_2 = create_node(label: 'Node 2', parent: @node_0)
    @node_3 = create_node(label: 'Node 3', parent: @node_1)

    # Tree:
    #
    # - node_0
    #   - node_1
    #     - node_3
    #   - node_2
  end

  before do
    visit project_node_path(current_node.project, current_node)
    click_link 'Action'
    click_link 'Merge'
  end

  let(:current_node) { @node_1 }

  describe 'merge of node into another node' do
    before do
      within_merge_node_modal do
        click_link(@node_2.label)
        find_button('Merge').click
      end
    end

    it 'deletes source node' do
      expect(Node.find_by(label: 'Node 1')).to eq nil
    end

    it 'moves child nodes into target node' do
      expect(@node_2.reload.children).to include(@node_3)
    end

    it 'navigates to target node path' do
      expect(current_path).to eq project_node_path(current_project, @node_2)
    end
  end

  def within_merge_node_modal
    within('#modal_merge_node') { yield }
  end

  def create_node(attrs={})
    create(:node, attrs.merge(project: current_project))
  end
end
