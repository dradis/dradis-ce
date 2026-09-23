require 'rails_helper'

describe 'Edit locking multi-actor flow' do
  describe 'for an issue' do
    let(:project) { create(:project) }
    let(:issue) { create(:issue, node: project.issue_library) }
    let(:record) { issue }
    let(:edit_path) { edit_project_issue_path(project, issue) }

    let(:submit_form) do
      find('.btn-states button[type="submit"]').click
      expect(page).to have_content('Issue updated.')
    end

    it_behaves_like 'a lockable resource'
  end

  describe 'for a note' do
    let(:project) { create(:project) }
    let(:node) { create(:node, project: project) }
    let(:note) { create(:note, node: node) }
    let(:record) { note }
    let(:edit_path) { edit_project_node_note_path(project, node, note) }

    let(:submit_form) { click_button 'Update Note' }

    it_behaves_like 'a lockable resource'
  end

  describe 'for a card' do
    let(:project) { create(:project) }
    let(:board) { create(:board, project: project) }
    let(:list) { create(:list, board: board) }
    let(:card) { create(:card, list: list) }
    let(:record) { card }
    let(:edit_path) { edit_project_board_list_card_path(project, board, list, card) }

    let(:submit_form) { click_button 'Update Card' }

    it_behaves_like 'a lockable resource'
  end

  describe 'for an issue edited from the QA space' do
    let(:project) { create(:project) }
    let(:issue) { create(:issue, node: project.issue_library, state: 'ready_for_review') }
    let(:record) { issue }
    let(:edit_path) { edit_project_qa_issue_path(project, issue) }

    let(:submit_form) do
      find('.btn-states button[type="submit"]').click
      expect(page).to have_content('Issue updated.')
    end

    it_behaves_like 'a lockable resource'
  end

  describe 'for a piece of evidence' do
    let(:project) { create(:project) }
    let(:node) { create(:node, project: project) }
    let(:evidence) { create(:evidence, node: node, issue: create(:issue, node: project.issue_library)) }
    let(:record) { evidence }
    let(:edit_path) { edit_project_node_evidence_path(project, node, evidence) }

    let(:submit_form) { click_button 'Update Evidence' }

    it_behaves_like 'a lockable resource'
  end

  describe 'for a piece of evidence reviewed from the QA space' do
    let(:project) { create(:project) }
    let(:node) { create(:node, project: project) }
    let(:qa_issue) { create(:issue, node: project.issue_library, state: 'ready_for_review') }
    let(:evidence) { create(:evidence, node: node, issue: qa_issue, state: 'ready_for_review') }
    let(:record) { evidence }
    let(:edit_path) { edit_project_qa_issue_evidence_path(project, qa_issue, evidence) }

    let(:submit_form) { click_button 'Update Evidence' }

    it_behaves_like 'a lockable resource'
  end
end
