# frozen_string_literal: true

require 'rails_helper'

describe 'merging a node', js: true do

  subject { page }

  let(:root_node) { create(:node) }

  before do
    login_to_project_as_user
  end

  let!(:source_node) { create(:node, label: 'Node-1', parent_id: root_node, project: current_project) }
  let!(:target_node) { create(:node, label: 'Node-2', parent_id: root_node, project: current_project) }

  before do
    visit project_node_path(source_node.project, source_node)
    find('[data-behavior~=nodes-more-dropdown]').click
    click_link 'Merge'
  end

  it 'redirects to the target node' do
    within_merge_node_modal do
      click_link(target_node.label)
      find_button('Merge').click
    end

    expect(current_path).to eq project_node_path(current_project, target_node)
  end

  it 'moves notes to target node' do
    note = create(:note, node: source_node)

    within_merge_node_modal do
      click_link(target_node.label)
      find_button('Merge').click
    end

    expect(target_node.notes).to include note
    expect(current_path).to eq project_node_path(current_project, target_node)
  end

  it 'moves evidence to target node' do
    evidence = create(:evidence, node: source_node)

    within_merge_node_modal do
      click_link(target_node.label)
      find_button('Merge').click
    end

    expect(target_node.evidence).to include evidence
  end

  it 'moves activity to target node' do
    activity = create(:activity, trackable: source_node)

    within_merge_node_modal do
      click_link(target_node.label)
      find_button('Merge').click
    end

    expect(target_node.activities).to include activity
  end

  it 'moves children to target node' do
    child_node = create(:node, parent: source_node, project: source_node.project)

    within_merge_node_modal do
      click_link(target_node.label)
      find_button('Merge').click
    end

    expect(target_node.children).to include child_node
  end

  it 'mergs properties with the target node' do
    source_node.properties['ip'] = ['1.1.1.1', '1.1.1.3']
    source_node.save

    target_node.properties['ip'] = ['1.1.1.1', '1.1.1.2']
    target_node.save

    within_merge_node_modal do
      click_link(target_node.label)
      find_button('Merge').click
    end

    expect(target_node.reload.properties['ip']).to eq ['1.1.1.1', '1.1.1.2', '1.1.1.3']
  end

  it 'moves attachments to target node' do
    create(:attachment, node: source_node)

    within_merge_node_modal do
      click_link(target_node.label)
      find_button('Merge').click
    end

    expect(target_node.attachments.count).to eq 1

    Attachment.all.each(&:delete)
  end

  it 'destroys the source node' do
    within_merge_node_modal do
      click_link(target_node.label)
      find_button('Merge').click
    end

    expect { Node.find(source_node.id) }.to raise_error ActiveRecord::RecordNotFound
  end

  def within_merge_node_modal
    within('#modal_merge_node') { yield }
  end
end
