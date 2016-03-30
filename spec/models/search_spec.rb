require "spec_helper"

describe Search do

  let(:setup_data) do
    create(:node, label: "test")
    create(:note, text: "test")
    create(:issue, text: "test")
    create(:evidence, content: "test")
  end

  describe "#all" do

    it "filters nodes, notes, issues, evidences by matching search term" do
      setup_data
      term = "test"

      search = Search.new(search_term: term, scope: "all")

      expect(search.results.size).to eq 5
    end

    it "shows count based on matched fields" do
      setup_data
      term = "test"

      search = Search.new(search_term: term, scope: "all")

      expect(search.total_count).to eq 5
      expect(search.notes_count).to eq 1
      expect(search.issues_count).to eq 2
      expect(search.nodes_count).to eq 1
      expect(search.evidences_count).to eq 1
    end
  end

  describe "#total_count" do
    it "returns 0 if noting founded" do
      term = "no-match"

      search = Search.new(search_term: term, scope: "all")

      expect(search.total_count).to eq 0
    end

    it "returns sum of all matched" do
      setup_data
      term = "test"

      search = Search.new(search_term: term, scope: "all")

      expect(search.total_count).to eq 5
    end
  end

  describe "#nodes_count" do
    it "returns 0 if noting founded" do
      term = "no-match"

      search = Search.new(search_term: term, scope: "all")

      expect(search.nodes_count).to eq 0
    end

    it "returns sum of all matched" do
      setup_data
      term = "test"

      search = Search.new(search_term: term, scope: "all")

      expect(search.nodes_count).to eq 1
    end
  end

  describe "#notes_count" do
    it "returns 0 if noting founded" do
      term = "no-match"

      search = Search.new(search_term: term, scope: "all")

      expect(search.notes_count).to eq 0
    end

    it "returns sum of all matched" do
      setup_data
      term = "test"

      search = Search.new(search_term: term, scope: "all")

      expect(search.notes_count).to eq 1
    end
  end

  describe "#issues_count" do
    it "returns 0 if noting founded" do
      term = "no-match"

      search = Search.new(search_term: term, scope: "all")

      expect(search.issues_count).to eq 0
    end

    it "returns sum of all matched" do
      setup_data
      term = "test"

      search = Search.new(search_term: term, scope: "all")

      expect(search.issues_count).to eq 2
    end
  end

  describe "#evidences_count" do
    it "returns 0 if noting founded" do
      term = "no-match"

      search = Search.new(search_term: term, scope: "all")

      expect(search.evidences_count).to eq 0
    end

    it "returns sum of all matched" do
      setup_data
      term = "test"

      search = Search.new(search_term: term, scope: "all")

      expect(search.evidences_count).to eq 1
    end
  end
end
