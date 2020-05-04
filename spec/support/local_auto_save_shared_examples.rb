# frozen_string_literal: true

# This local shared example needs the following *let* variables
# - new_model_path: the path to create a new model
# - new_model_attributes: attributes to fill in the form
# - new_model_attributes_for_template: attributses to fill in the form with template

# let(:new_model_path) { new_project_board_list_card_path(current_project, @board, @list) }
# let(:new_model_attributes) {
#   [
#     { name: :name, value: 'New Card' },
#     { name: :description, value: 'New Description' },
#     { name: :due_date, value: Date.today }
#   ]
# }

# include_examples 'a form with local auto save', Card

shared_examples 'a form with local auto save' do |klass|
  before do
    add_users if klass == Card
    add_tags if klass == Issue
    add_categories if klass == Note

    visit new_model_path
    click_link 'Source'

    if klass == Card
      check @first_user.name
    elsif klass == Evidence
      select @issue_1.title, from: :evidence_issue_id
    elsif klass == Issue
      dropdown_toggle = page.find('.dropdown-toggle span.tag')
      dropdown_toggle.click
      click_on @tag_1.display_name
    elsif klass == Note
      select @category_1.name, from: :note_category_id
    end

    new_model_attributes.each do |model_attribute|
      fill_in "#{klass.name.downcase}_#{model_attribute[:name]}", with: model_attribute[:value]
    end

    sleep 1 # Needed for debounce function in local_auto_save.js
  end

  context 'when form is not saved' do
    it 'prefill fields with cached data' do
      page.driver.browser.navigate.refresh
      click_link 'Source'

      if klass == Card
        expect(page.find("input#card_assignee_ids_#{@first_user.id}")).to be_checked
      elsif klass == Evidence
        expect(page).to have_select('evidence_issue_id', selected: @issue_1.title)
      elsif klass == Issue
        expect(page).to have_button(@tag_1.display_name)
      elsif klass == Note
        expect(page).to have_select('note_category_id', selected: @category_1.name)
      end

      new_model_attributes.each do |model_attribute|
        if model_attribute[:value].is_a?(Date)
          expect(page.find_field("#{klass.name.downcase}[#{model_attribute[:name]}]").value).to eq model_attribute[:value].to_date.strftime('%Y-%m-%d')
        else
          expect(page.find_field("#{klass.name.downcase}[#{model_attribute[:name]}]").value).to eq model_attribute[:value]
        end
      end
    end
  end

  context 'when form is saved' do
    it 'clears cached data' do
      page.find('input[type="submit"]').click
      visit new_model_path
      click_link 'Source'

      if klass == Card
        expect(page.find("input#card_assignee_ids_#{@first_user.id}")).not_to be_checked
      elsif klass == Evidence
        expect(page).to have_select('evidence_issue_id', selected: 'Choose an Issue')
      elsif klass == Issue
        expect(page).to have_css('.dropdown-toggle span.tag', text: 'No tag')
      elsif klass == Note
        expect(page).to have_select('note_category_id', selected: 'Assign note category')
      end

      new_model_attributes.each do |model_attribute|
        expect(page.find_field("#{klass.name.downcase}[#{model_attribute[:name]}]").value).to eq ''
      end
    end
  end

  context 'when Cancel is clicked' do
    it 'clears cached data' do
      click_link 'Cancel'
      visit new_model_path
      click_link 'Source'

      new_model_attributes.each do |model_attribute|
        expect(page.find_field("#{klass.name.downcase}[#{model_attribute[:name]}]").value).to eq ''
      end
    end
  end
end
