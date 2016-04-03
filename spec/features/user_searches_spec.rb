require "spec_helper"

describe "User searches", type: :feature do
  before do
    sign_in
  end

  it "can access search on main navigation" do
    within ".navbar" do
      expect(page).to have_css "#q"
      expect(page).to have_css "#search_btn"
    end
  end

  it "when click on search button search results form is shown" do
    fill_in "q", with: "test"
    click_on "search_btn"

    expect(page.current_path).to eq search_path
    expect(page).to have_content "Search results"
  end

  context "search results" do
    it "can see all results that are matched when on all tab" do
      setup_test_data
      term = "search"

      page.find(".navbar-search #q").set(term)
      click_on "search_btn"

      within "#tbl-search" do
        expect(page).to have_content "Node search"
        expect(page).to have_content "Issue search"
        expect(page).to have_content "Note search"
        expect(page).to have_content "Evidence search"
      end
    end

    it "dosen't see results that are not matched" do
      setup_test_data
      ghost = create(:node, label: "Node ghost")
      term = "search"

      page.find(".navbar-search #q").set(term)
      click_on "search_btn"

      within "#tbl-search" do
        expect(page).to_not have_content ghost.label
      end
    end

    it "clicking on node tab sees only matched nodes" do
      setup_test_data
      term = "search"
      page.find(".navbar-search #q").set(term)
      click_on "search_btn"

      page.find(".search-nav #nodes").click

      within "#tbl-search" do
        expect(page).to have_content "Node search"

        expect(page).to_not have_content "Issue search"
        expect(page).to_not have_content "Note search"
        expect(page).to_not have_content "Evidence search"
      end
    end

    it "clicking on note tab sees only matched notes" do
      setup_test_data
      term = "search"
      page.find(".navbar-search #q").set(term)
      click_on "search_btn"

      page.find(".search-nav #notes").click

      within "#tbl-search" do
        expect(page).to have_content "Note search"

        expect(page).to_not have_content "Node search"
        expect(page).to_not have_content "Issue search"
        expect(page).to_not have_content "Evidence search"
      end
    end

    it "clicking on issues tab sees only matched issues" do
      setup_test_data
      term = "search"
      page.find(".navbar-search #q").set(term)
      click_on "search_btn"

      page.find(".search-nav #issues").click

      within "#tbl-search" do
        expect(page).to have_content "Issue search"

        expect(page).to_not have_content "Note search"
        expect(page).to_not have_content "Node search"
        expect(page).to_not have_content "Evidence search"
      end
    end

    it "clicking on evidences tab sees only matched evidences" do
      setup_test_data
      term = "search"
      page.find(".navbar-search #q").set(term)
      click_on "search_btn"

      page.find(".search-nav #evidences").click

      within "#tbl-search" do
        expect(page).to have_content "Evidence search"

        expect(page).to_not have_content "Issue search"
        expect(page).to_not have_content "Note search"
        expect(page).to_not have_content "Node search"
      end
    end

    it "sees message warning when no search criteria entered" do
      click_on "search_btn"

      expect(page).to have_css ".search-no-matches", text: "Please enter search criteria"
    end

    it "sees message warning when no matches find" do
      page.find(".navbar-search #q").set("no matches")

      click_on "search_btn"

      expect(page).to have_css ".search-no-matches", text: "No matches found!"
    end
  end
end

def setup_test_data
  create(:issue, text: "Issue search")
  node = create(:node, label: "Node search")
  create(:note, text: "Note search", node: node)
  create(:evidence, content: "Evidence search")
end
