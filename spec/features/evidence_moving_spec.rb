require 'rails_helper'

describe 'moving an evidence', js: true do
  subject { page }

  before do
    login_to_project_as_user

    def create_node(label, parent = nil)
      create(:node, label: label, parent: parent, project: current_project)
    end

    # Tree:
    #
    # - node_0
    #   - node_2
    #     - node_5
    #   - node_3
    # - node_1
    #   - node_4
    @node_0 = create_node('Node 0')
    @node_1 = create_node('Node 1')
    @node_2 = create_node('Node 2', @node_0)
    @node_3 = create_node('Node 3', @node_0)
    @node_4 = create_node('Node 4', @node_1)
    @node_5 = create_node('Node 5', @node_2)

    visit project_node_evidence_path(current_project, @node_5, current_evidence)
    click_move_evidence
  end

  let(:current_evidence) { @evidence = create(:evidence, node: @node_5) }

  describe 'moving an evidence to a different node' do
    before do
      within('#modal_move_evidence') do
        click_link @node_1.label
        click_submit
      end
    end

    it 'should update the evidence\'s node_id' do
      expect(current_evidence.reload.node_id).to eq(@node_1.id)
    end

    it 'should redirect to evidence show path' do
      expect(current_path).to eq(project_node_evidence_path(current_project, @node_1, current_evidence))
    end
  end

  describe 'moving a evidence to a similar node' do
    before do
      within('#modal_move_evidence') do
        click_link @node_5.label
        click_submit
      end
    end

    it 'should update the node as an invalid selection' do
      expect(find('.invalid-selection').text).to eq(@node_5.label)
    end
  end

  def click_move_evidence
    within('.dots-container') do
      find('.dots-dropdown').click
      find('a[href="#modal_move_evidence"]').click
    end
  end

  def click_submit
    find('.btn-primary').click
  end
end
