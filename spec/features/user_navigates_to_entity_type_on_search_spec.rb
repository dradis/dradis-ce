require "spec_helper"

describe "User navigates to entity page from search" do

  before do
    login_to_project_as_user
    visit root_path
  end

  context "when click on title link" do
    it 'of node opens the node page' do
      node = create(:node, label: "Node search")
      visit search_path(q: node.label)

      page.find(".search-match-title").click

      expect(page.current_path).to eq node_path(node)
    end

    it 'of note opens the note page' do
      note = create(:note, text: "Note search")
      visit search_path(q: note.text)

      page.find(".search-match-title").click

      expect(page.current_path).to eq node_note_path(note.node_id, note)
    end

    it 'of issue opens the issue page' do
      issue = create(:issue, text: "Issue search")
      visit search_path(q: issue.text)

      page.find(".search-match-title").click

      expect(page.current_path).to eq issue_path(issue)
    end

    it 'of evidence opens to node page' do
      evidence = create(:evidence, content: "Evidence search")
      visit search_path(q: evidence.content)

      page.find(".search-match-title").click

      expect(page.current_path).to eq node_evidence_path(evidence.node_id, evidence)
    end
  end
end
