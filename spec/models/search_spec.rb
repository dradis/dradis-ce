require 'rails_helper'

describe Search do
  let(:project) { Project.new }

  let(:setup_data) do
    node = create(:node, label: "test", project: project)
    create(:note, text: "test")
    create(:issue, text: "test")
    create(:evidence, content: "test", node: node)
  end

  describe "#all" do

    it "filters nodes, notes, issues, evidence by matching search term" do
      setup_data
      q = "test"

      results = Search.new(query: q, scope: :all, project: project).results
      expect(results.size).to eq 4
    end

    it "shows count based on matched fields" do
      setup_data
      q = "test"

      search = Search.new(query: q, scope: :all, project: project)

      expect(search.total_count).to eq 4
      expect(search.notes_count).to eq 1
      expect(search.issues_count).to eq 1
      expect(search.nodes_count).to eq 1
      expect(search.evidence_count).to eq 1
    end
  end

  describe "#total_count" do
    it "returns 0 if nothing found" do
      q = "no-match"

      search = Search.new(query: q, scope: :all, project: project)

      expect(search.total_count).to eq 0
    end

    it "returns sum of all matched" do
      setup_data
      q = "test"

      search = Search.new(query: q, scope: :all, project: project)

      expect(search.total_count).to eq 4
    end
  end

  describe "#nodes_count" do
    it "returns 0 if nothing found" do
      q = "no-match"

      search = Search.new(query: q, scope: :all, project: project)

      expect(search.nodes_count).to eq 0
    end

    it "returns sum of all matched" do
      setup_data
      q = "test"

      search = Search.new(query: q, scope: :all, project: project)

      expect(search.nodes_count).to eq 1
    end
  end

  describe "#notes_count" do
    it "returns 0 if nothing found" do
      q = "no-match"

      search = Search.new(query: q, scope: :all, project: project)

      expect(search.notes_count).to eq 0
    end

    it "returns sum of all matched" do
      setup_data
      q = "test"

      search = Search.new(query: q, scope: :all, project: project)

      expect(search.notes_count).to eq 1
    end
  end

  describe "#issues_count" do
    it "returns 0 if nothing found" do
      q = "no-match"

      search = Search.new(query: q, scope: :all, project: project)

      expect(search.issues_count).to eq 0
    end

    it "returns sum of all matched" do
      setup_data
      q = "test"

      search = Search.new(query: q, scope: :all, project: project)

      expect(search.issues_count).to eq 1
    end
  end

  describe "#evidence_count" do
    it "returns 0 if nothing found" do
      q = "no-match"

      search = Search.new(query: q, scope: :all, project: project)

      expect(search.evidence_count).to eq 0
    end

    it "returns sum of all matched" do
      setup_data
      q = "test"

      search = Search.new(query: q, scope: :all, project: project)

      expect(search.evidence_count).to eq 1
    end
  end


  describe "#evidence" do
    it "filters evidences by content matching search term" do
      first = create(:evidence, content: "First evidence")
      second = create(:evidence, content: "Second evidence")


      results = described_class.new(query: 'first', scope: :evidence, project: project).results
      expect(results.size).to eq 1
      expect(results.first.content).to eq first.content
    end

    it "returns list of matches order by updated_at desc" do
      # Without specifying :updated_at, CI would fail to sort properly
      first = create(:evidence, content: "First evidence", updated_at: 10.seconds.ago)
      second = create(:evidence, content: "Second evidence", updated_at: 5.seconds.ago)

      results = described_class.new(query: 'evidence', scope: :evidence, project: project).results
      expect(results.map(&:content)).to eq [second.content, first.content]
    end

    it "behaves as case insensitive search" do
      issue = create(:evidence, content: "Evidence")

      results = described_class.new(query: 'eviDencE', scope: :evidence, project: project).results
      expect(results.size).to eq 1
      expect(results.first.content).to eq issue.content
    end
  end

  describe "#issues" do
    it "filters issues by text matching search term" do
      first  = create(:issue, text: "First issue")
      second = create(:issue, text: "Second issue")

      results = Search.new(query: 'first', scope: :issues, project: project).results

      expect(results.size).to eq 1
      expect(results.first.text).to eq first.text
    end

    it "excludes normal notes" do
      issue = create(:issue, text: "Issue note")
      note  = create(:note, text: "First note", category: issue.category)

      results = Search.new(query: 'first', scope: :issues, project: project).results
      expect(results.size).to eq 0
    end

    it "returns list of matches order by updated_at desc" do
      # Without specifying :updated_at, CI would fail to sort properly
      first  = create(:issue, text: "First issue", updated_at: 10.seconds.ago)
      second = create(:issue, text: "Second issue", updated_at: 5.seconds.ago)

      results = Search.new(query: 'issue', scope: :issues, project: project).results

      expect(results.map(&:text)).to eq [second.text, first.text]
    end

    it "behaves as case insensitive search" do
      issue = create(:issue, text: "Issue")

      results = Search.new(query: 'ISSuE', scope: :issues, project: project).results

      expect(results.size).to eq 1
      expect(results.first.text).to eq issue.text
    end
  end

  describe "#nodes" do
    it "filters nodes by label matching search term" do
      first  = create(:node, label: "First node")
      second = create(:node, label: "Second node")


      results = described_class.new(query: 'first', scope: :nodes, project: project).results
      expect(results.size).to eq 1
      expect(results.first.label).to eq first.label
    end

    it "returns list of matches ordered by updated_at desc" do
      # Without specifying :updated_at, CI would fail to sort properly
      first  = create(:node, label: "First node", updated_at: 10.seconds.ago)
      second = create(:node, label: "Second node", updated_at: 5.seconds.ago)

      results = described_class.new(query: 'node', scope: :nodes, project: project).results
      expect(results.map(&:label)).to eq [second.label, first.label]
    end

    it "filters excludes issues and methodology type" do
      node = create(:node, label: "First node")
      project.issue_library
      project.methodology_library

      results = described_class.new(query: 'node', scope: :nodes, project: project).results
      expect(results.size).to eq 1
      expect(results.first.label).to eq node.label
    end

    it "behaves as case insensitive search" do
      node = create(:node, label: "Node")

      results = described_class.new(query: 'nODE', scope: :nodes, project: project).results
      expect(results.size).to eq 1
      expect(results.first.label).to eq node.label
    end
  end

  describe "#notes" do
    it "filters notes by content matching search term" do
      first  = create(:note, text: "First note", category: Category.default)
      second = create(:note, text: "Second note", category: Category.default)

      results = Search.new(query: 'first', scope: :notes, project: project).results

      expect(results.size).to eq 1
      expect(results.first.text).to eq first.text
    end

    it "excludes issue notes" do
      issue = create(:issue, text: "Issue note")
      note  = create(:note, text: "First note", category: issue.category)

      results = Search.new(query: 'issue', scope: :notes, project: project).results
      expect(results.size).to eq 0
    end

    it "returns list of matches order by updated_at desc" do
      # Without specifying :updated_at, CI would fail to sort properly
      first  = create(:note, text: "First note", category: Category.default, updated_at: 10.seconds.ago)
      second = create(:note, text: "Second note", category: Category.default, updated_at: 5.seconds.ago)

      results = Search.new(query: 'note', scope: :notes, project: project).results
      expect(results.map(&:text)).to eq [second.text, first.text]
    end

    it "behaves as case insensitive search" do
      note = create(:note, text: "note", category: Category.default)

      results = Search.new(query: 'NOTE', scope: :notes, project: project).results

      expect(results.size).to eq 1
      expect(results.first.text).to eq note.text
    end
  end
end
