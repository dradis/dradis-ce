require 'rails_helper'

describe 'Local auto save', js: true do
  before { login_to_project_as_user }
  context 'issue form' do
    let!(:tags) do
      [
        current_project.tags.create(name: '!9467bd_critical'),
        current_project.tags.create(name: '!d62728_high')
      ]
    end

    it 'caches tags and source/fields view inputs' do
      visit new_project_issue_path(current_project)
      click_link 'Source'

      fill_in 'issue_text', with: 'New issue'

      dropdown_toggle = page.find('.dropdown-toggle span.tag')
      dropdown_toggle.click
      click_on tags[0].display_name
      sleep 1 # Needed for debounce function

      page.refresh

      expect(page).to have_button(tags[0].display_name)
      expect(page).to have_field('issue_text', with: 'New issue')

      click_link 'Fields'

      fill_in 'item_form_field_name_0', with: 'Title'
      fill_in 'item_form_field_value_0', with: 'New issue'
      sleep 1

      expect(page).to have_field('item_form_field_name_0', with: 'Title')
      expect(page).to have_field('item_form_field_value_0', with: 'New issue')
    end
  end

  describe 'card form' do
    let(:board) { create(:board, project: current_project, node: current_project.methodology_library) }
    let(:list) { create(:list, board: board) }
    let!(:users) { create_list(:user, 2, :author) }

    it 'caches date inputs and checkboxes' do
      visit new_project_board_list_card_path(current_project, board, list)

      fill_in 'card_due_date', with: Date.today
      check users[0].name
      sleep 1 # Needed for debounce function

      page.refresh

      expect(page).to have_field('card_due_date', with: Date.today.strftime('%Y-%m-%d'))
      expect(page.find("input#card_assignee_ids_#{users[0].id}")).to be_checked
    end
  end

  describe 'note form' do
    let!(:categories) { create_list(:category, 2) }
    let(:node) { create(:node, project: current_project) }

    it 'caches select input' do
      visit new_project_node_note_path(current_project, node)

      select categories[0].name, from: :note_category_id
      sleep 1 # Needed for debounce function

      page.refresh

      expect(page).to have_select('note_category_id', selected: categories[0].name)
    end
  end

  describe 'clearing cache' do
    let(:cache_issue_text) do
      visit new_project_issue_path(current_project)
      click_link 'Source'
      fill_in 'issue_text', with: 'New issue'
      sleep 1 # Needed for debounce function
    end

    it 'clears the cache when form is saved or when "Cancel" is clicked' do
      cache_issue_text
      page.find('input[type="submit"]').click
      visit new_project_issue_path(current_project)

      expect(page.find_field('issue[text]').value).to eq ''

      cache_issue_text
      within('.view-content') do
        scroll_to(:bottom)
      end
      click_link 'Cancel'
      visit new_project_issue_path(current_project)

      expect(page.find_field('issue[text]').value).to eq ''
    end
  end
end
