require 'rails_helper'

describe 'Local auto save', js: true do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, node: current_project.issue_library) }

  let(:board) { create(:board, project: current_project, node: current_project.methodology_library) }
  let(:list) { create(:list, board: board) }

  let!(:users) do
    user1 = create(:user, :author)
    user2 = create(:user, :author)

    [
      user1,
      user2
    ]
  end

  describe 'custom tag input' do
    let!(:tags) do
      [
        current_project.tags.create(name: '!9467bd_critical'),
        current_project.tags.create(name: '!d62728_high')
      ]
    end

    it 'will be cached' do
      visit new_project_issue_path(current_project)

      dropdown_toggle = page.find('.dropdown-toggle span.tag')
      dropdown_toggle.click
      click_on tags[0].display_name
      sleep 1 # Needed for debounce function

      page.refresh

      expect(page).to have_button(tags[0].display_name)
    end
  end

  describe 'source/fields view inputs' do
    before do
      visit new_project_issue_path(current_project)
    end

    it 'will be cached' do
      click_link 'Source'

      fill_in 'issue_text', with: 'New issue'
      sleep 1 # Needed for debounce function

      expect(page).to have_field('issue_text', with: 'New issue')
    end

    it 'will be cached' do
      click_link 'Fields'

      fill_in 'item_form_field_name_0', with: 'Title'
      fill_in 'item_form_field_value_0', with: 'New issue'
      sleep 1 # Needed for debounce function

      page.refresh

      expect(page).to have_field('item_form_field_name_0', with: 'Title')
      expect(page).to have_field('item_form_field_value_0', with: 'New issue')
    end
  end

  describe 'date input' do
    it 'will be cached' do
      visit new_project_board_list_card_path(current_project, board, list)

      fill_in 'card_due_date', with: Date.today
      sleep 1 # Needed for debounce function

      page.refresh
      expect(page).to have_field('card_due_date', with: Date.today.strftime('%Y-%m-%d'))
    end
  end

  describe 'checkboxes' do
    it 'will be cached' do
      visit new_project_board_list_card_path(current_project, board, list)

      check users[0].name
      sleep 1 # Needed for debounce function

      expect(page.find("input#card_assignee_ids_#{users[0].id}")).to be_checked
    end
  end

  describe 'select input' do
    let(:node) { create(:node, project: current_project) }

    let!(:categories) do
      [
        create(:category),
        create(:category)
      ]
    end

    it 'will be cached' do
      visit new_project_node_note_path(current_project, node)

      select categories[0].name, from: :note_category_id
      sleep 1 # Needed for debounce function

      expect(page).to have_select('note_category_id', selected: categories[0].name)
    end
  end

  describe 'clearing cache' do
    before do
      visit new_project_issue_path(current_project)
      click_link 'Source'
      fill_in 'issue_text', with: 'New issue'
      sleep 1 # Needed for debounce function
    end

    context 'when form is saved' do
      it 'clears the cache' do
        page.find('input[type="submit"]').click
        visit new_project_issue_path(current_project)

        expect(page.find_field('issue[text]').value).to eq ''
      end
    end

    context 'when "Cancel" link is clicked' do
      it 'clears the cache' do
        within('.view-content') do
          scroll_to(:bottom)
        end

        click_link 'Cancel'
        visit new_project_issue_path(current_project)

        expect(page.find_field('issue[text]').value).to eq ''
      end
    end
  end
end
