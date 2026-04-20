require 'rails_helper'

describe 'User searches', type: :feature do
  def setup_test_data
    issue = create(:issue, text: 'Issue search', node: current_project.issue_library)
    node = create(:node, label: 'Node search', project: current_project)
    create(:note, text: 'Note search', node: node)
    create(:evidence, content: 'Evidence search', issue: issue, node: node)
  end

  before do
    login_to_project_as_user
    visit project_path(current_project)
  end

  it 'can access search on main navigation' do
    within '.sub-nav' do
      expect(page).to have_css '#q'
      expect(page).to have_css '#search-btn'
    end
  end

  it 'when click on search button search results form is shown', :js do
    within '.sub-nav' do
      fill_in 'q', with: 'test', visible: false
      click_on 'search-btn'
    end
    expect(page.current_path).to eq project_search_path(current_project)
    expect(page).to have_content 'Search Results: test'
  end

  context 'search results' do
    it 'can see all results that are matched when on all tab' do
      setup_test_data
      term = 'search'

      page.find('.sub-nav #q').set(term)
      within '.sub-nav' do
        click_on 'search-btn'
      end

      within '#tbl-search' do
        expect(page).to have_css '.node-result'
        expect(page).to have_css '.issue-result'
        expect(page).to have_css '.note-result'
        expect(page).to have_css '.evidence-result'
      end
    end

    it "dosen't see results that are not matched" do
      setup_test_data
      ghost = create(:node, label: 'Node ghost')
      term = 'search'

      page.find('.sub-nav #q').set(term)
      within '.sub-nav' do
        click_on 'search-btn'
      end

      within '#tbl-search' do
        expect(page).to_not have_content ghost.label
      end
    end

    it 'clicking on node tab sees only matched nodes' do
      setup_test_data
      term = 'search'
      page.find('.sub-nav #q').set(term)
      within '.sub-nav' do
        click_on 'search-btn'
      end

      page.find('.search-nav #nodes').click

      within '#tbl-search' do
        expect(page).to have_css '.node-result'

        expect(page).to_not have_css '.issue-result'
        expect(page).to_not have_css '.note-result'
        expect(page).to_not have_css '.evidence-result'
      end
    end

    it 'clicking on note tab sees only matched notes' do
      setup_test_data
      term = 'search'
      page.find('.sub-nav #q').set(term)
      within '.sub-nav' do
        click_on 'search-btn'
      end

      page.find('.search-nav #notes').click

      within '#tbl-search' do
        expect(page).to have_css '.note-result'

        expect(page).to_not have_css '.node-result'
        expect(page).to_not have_css '.issue-result'
        expect(page).to_not have_css '.evidence-result'
      end
    end

    it 'clicking on issues tab sees only matched issues' do
      setup_test_data
      term = 'search'
      page.find('.sub-nav #q').set(term)
      within '.sub-nav' do
        click_on 'search-btn'
      end

      page.find('.search-nav #issues').click

      within '#tbl-search' do
        expect(page).to have_css '.issue-result'

        expect(page).to_not have_css '.note-result'
        expect(page).to_not have_css '.node-result'
        expect(page).to_not have_css '.evidence-result'
      end
    end

    it 'clicking on evidences tab sees only matched evidences' do
      setup_test_data
      term = 'search'
      page.find('.sub-nav #q').set(term)

      within '.sub-nav' do
        click_on 'search-btn'
      end

      page.find('.search-nav #evidences').click

      within '#tbl-search' do
        expect(page).to have_css '.evidence-result'

        expect(page).to_not have_css '.issue-result'
        expect(page).to_not have_css '.note-result'
        expect(page).to_not have_css '.node-result'
      end
    end

    it 'sees message warning when no search criteria entered' do
      within '.sub-nav' do
        click_on 'search-btn'
      end

      expect(page).to have_content 'Please enter search criteria'
    end

    it 'sees message warning when no matches find' do
      page.find('.sub-nav #q').set('no matches')

      within '.sub-nav' do
        click_on 'search-btn'
      end

      expect(page).to have_content 'No matches found!'
    end
  end
end
