require 'rails_helper'

describe 'Tab memory markup' do
  before { login_to_project_as_user }

  let(:node) { create(:node, project: current_project) }

  context 'on Issues' do
    let(:issue) { create(:issue, node: current_project.issue_library) }
    let(:tab_memory_key) { "issue_#{issue.id}" }
    let(:tab_memory_path) { project_issue_path(current_project, issue) }

    it_behaves_like 'a tab strip with memory'
  end

  context 'on QA Issues' do
    let(:issue) { create(:issue, node: current_project.issue_library, state: :ready_for_review) }
    let(:tab_memory_key) { "qa_issue_#{issue.id}" }
    let(:tab_memory_path) { project_qa_issue_path(current_project, issue) }

    it_behaves_like 'a tab strip with memory'
  end

  context 'on Nodes' do
    let(:tab_memory_key) { "node_#{node.id}" }
    let(:tab_memory_path) { project_node_path(current_project, node) }

    it_behaves_like 'a tab strip with memory'
  end

  context 'on Notes' do
    let(:note) { create(:note, node: node) }
    let(:tab_memory_key) { "note_#{note.id}" }
    let(:tab_memory_path) { project_node_note_path(current_project, node, note) }

    it_behaves_like 'a tab strip with memory'
  end

  context 'on Evidence' do
    let(:evidence) { create(:evidence, node: node) }
    let(:tab_memory_key) { "evidence_#{evidence.id}" }
    let(:tab_memory_path) { project_node_evidence_path(current_project, node, evidence) }

    it_behaves_like 'a tab strip with memory'
  end

  context 'on Cards' do
    let(:board) { create(:board, project: current_project) }
    let(:list) { create(:list, board: board) }
    let(:card) { create(:card, list: list) }
    let(:tab_memory_key) { "card_#{card.id}" }
    let(:tab_memory_path) { project_board_list_card_path(current_project, board, list, card) }

    it_behaves_like 'a tab strip with memory'
  end

  context 'on Export' do
    let(:tab_memory_key) { "export_project_#{current_project.id}" }
    let(:tab_memory_path) { project_export_manager_path(current_project) }

    it_behaves_like 'a tab strip with memory'
  end
end
