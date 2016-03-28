require "spec_helper"

describe Search do
  describe "#issues" do
    it "searches issues by text using case insensitive like"  do
      first_issue = create(:issue, text: "First issue")
      second_issue = create(:issue, text: "Second issue")
      search_term = "first"

      search = Search.new(search_term: search_term)

      expect(search.issues.size).to eq 1
      expect(search.issues.map(&:text)).to eq [first_issue.text]
    end
  end

  describe "#nodes" do
    it "searches nodes by label using case insensitive like"  do
      first_node = create(:node, label: "Node First")
      second_node = create(:node, label: "Node Second")
      search_term = "first"

      search = Search.new(search_term: search_term)

      expect(search.nodes.size).to eq 1
      expect(search.nodes.map(&:label)).to eq [first_node.label]
    end
  end

  describe "#notes" do
    it "searches nodes by text using case insensitive like"  do
      first_note = create(:note, text: "Note First")
      second_note = create(:note, text: "Note Second")
      search_term = "first"

      search = Search.new(search_term: search_term)

      expect(search.notes.size).to eq 1
      expect(search.notes.map(&:text)).to eq [first_note.text]
    end
  end

  describe "#evidences" do
    it "searches nodes by content using case insensitive like"  do
      first_evidence = create(:evidence, content: "Evidence First")
      second_evidence = create(:evidence, content: "Evidence Second")
      search_term = "first"

      search = Search.new(search_term: search_term)

      expect(search.evidences.size).to eq 1
      expect(search.evidences.map(&:content)).to eq [first_evidence.content]
    end
  end
end
