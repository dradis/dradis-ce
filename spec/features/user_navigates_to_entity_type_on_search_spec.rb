require 'rails_helper'

describe "User navigates to entity page from search" do

  before do
    login_to_project_as_user
    visit root_path
  end

  context "when click on title link" do
    it 'of node opens the node page' do
      node = create(:node, label: 'Node search', project: @project)
      visit project_search_path(current_project, q: node.label)

      page.find(".search-match-title").click

      expect(page.current_path).to eq project_node_path(node.project, node)
    end

    it 'of note opens the note page' do
      node = create(:node, project: @project)
      note = create(:note, text: 'Note search', node: node)
      visit project_search_path(current_project, q: note.text)

      page.find(".search-match-title").click

      expect(page.current_path).to eq project_node_note_path(current_project, note.node_id, note)
    end

    it 'of issue opens the issue page' do
      issue = create(:issue, text: 'Issue search', node: @project.issue_library)
      visit project_search_path(current_project, q: issue.text)

      page.find(".search-match-title").click

      expect(page.current_path).to eq project_issue_path(current_project, issue)
    end

    it 'of evidence opens to node page' do
      issue = create(:issue, text: 'Issue search', node: @project.issue_library)
      node = create(:node, project: @project)
      evidence = create(:evidence, content: 'Evidence search', node: node, issue: issue)
      visit project_search_path(current_project, q: evidence.content)

      page.find(".search-match-title").click

      expect(page.current_path).to eq project_node_evidence_path(current_project, evidence.node_id, evidence)
    end
  end
end
