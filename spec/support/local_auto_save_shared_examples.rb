# frozen_string_literal: true

# This local shared example needs the following *let* variables
# - model_path: the path to create a new model
# - model_attributes: attributes to fill in the form
# - model_attributes_for_template: attributses to fill in the form with template

# let(:model_path) { new_project_board_list_card_path(current_project, @board, @list) }
# let(:model_attributes) do
#   [
#     { name: :name, value: 'New Card' },
#     { name: :description, value: 'New Description' },
#     { name: :due_date, value: Date.today }
#   ]
# end
#
# let(:model_attributes_for_template) do
#   [
#     { name: :name, value: 'New Card Template' },
#     { name: :description, value: 'New Description Template' },
#     { name: :due_date, value: Date.today + 5.day }
#   ]
# end
#
# include_examples 'a form with local auto save', Card

shared_examples 'a form with local auto save' do |klass, action|
  let(:form_object_name) { klass.name.underscore }

  before do
    add_users if klass == Card
    add_tags if klass == Issue

    visit model_path
    click_link 'Source'

    if klass == Card
      check @first_user.name
    elsif klass == Evidence
      find('#evidence_issue_id + .combobox').click
      find('.combobox-menu .combobox-option', text:  @issue_1.title).click
    elsif klass == Issue
      dropdown_toggle = page.find('.dropdown-toggle span.tag')
      dropdown_toggle.click
      click_on @tag_1.display_name
    end

    model_attributes.each do |model_attribute|
      fill_in "#{form_object_name}_#{model_attribute[:name]}", with: model_attribute[:value]
    end

    sleep 1 # Needed for debounce function in local_auto_save.js
  end

  context 'when form is not saved' do
    it 'prefill fields with cached data' do
      page.driver.browser.navigate.refresh
      click_link 'Source'

      if action == :new
        if klass == Card
          expect(page.find("input#card_assignee_ids_#{@first_user.id}")).to be_checked
        elsif klass == Evidence
          expect(page).to have_select('evidence_issue_id', selected: @issue_1.title, visible: false)
        elsif klass == Issue
          expect(page).to have_button(@tag_1.display_name)
        end
      end

      model_attributes.each do |model_attribute|
        if model_attribute[:value].is_a?(Date)
          expect(page.find_field("#{form_object_name}[#{model_attribute[:name]}]").value).to eq model_attribute[:value].to_date.strftime('%Y-%m-%d')
        else
          expect(page.find_field("#{form_object_name}[#{model_attribute[:name]}]").value).to eq model_attribute[:value]
        end
      end
    end
  end

  context 'when form is saved' do
    it 'clears cached data' do
      within '.content-container' do
        page.find('[type="submit"]').click
      end
      visit model_path
      click_link 'Source'

      if action == :new
        if klass == Card
          expect(page.find("input#card_assignee_ids_#{@first_user.id}")).not_to be_checked
        elsif klass == Evidence
          expect(page).to have_select('evidence_issue_id', selected: 'Auto-generate a new issue', visible: false)
        elsif klass == Issue
          expect(page).to have_css('.dropdown-toggle span.tag', text: 'No tag')
        end
      end

      model_attributes.each do |model_attribute|
        expect(page.find_field("#{form_object_name}[#{model_attribute[:name]}]").value).not_to eq model_attribute[:name]
      end
    end
  end

  context 'when Cancel is clicked' do
    it 'clears cached data' do
      within('[data-behavior="view-content"]') do
        scroll_to(:bottom)
      end
      click_link 'Cancel'
      visit model_path
      click_link 'Source'

      model_attributes.each do |model_attribute|
        expect(page.find_field("#{form_object_name}[#{model_attribute[:name]}]").value).not_to eq model_attribute[:name]
      end
    end
  end

  if action == :new
    describe 'with template' do
      if [Card, Evidence, Note, Issue].include? klass
        before do
          template_path = Rails.root.join('spec/fixtures/files/note_templates/')
          allow(NoteTemplate).to receive(:pwd).and_return(template_path)
          visit "#{model_path}?template=simple_note"
          click_link 'Source'
          @template_content = File.read(template_path.join('simple_note.txt'))

          model_attributes_for_template.each do |model_attribute|
            fill_in "#{form_object_name}_#{model_attribute[:name]}", with: model_attribute[:value]
          end

          sleep 1 # Needed for debounce function in local_auto_save.js
        end
      end

      context 'when form is not saved' do
        it 'prefill fields with cached data' do
          page.driver.browser.navigate.refresh
          click_link 'Source'

          model_attributes_for_template.each do |model_attribute|
            if model_attribute[:value].is_a?(Date)
              expect(page.find_field("#{form_object_name}[#{model_attribute[:name]}]").value).to eq model_attribute[:value].to_date.strftime('%Y-%m-%d')
            else
              expect(page.find_field("#{form_object_name}[#{model_attribute[:name]}]").value).to eq model_attribute[:value]
            end
          end
        end
      end

      context 'when form is saved' do
        it 'does not prefill fields with cached data' do
          # Fixed weird bug where submit button not in viewport for Card form
          page.execute_script('$("#view-content").scrollTop(10000)')

          within '.content-container' do
            page.find('[type="submit"]').click
          end
          visit "#{model_path}?template=simple_note"
          click_link 'Source'

          page_form_values = model_attributes_for_template.collect do |model_attribute|
            page.find_field("#{form_object_name}[#{model_attribute[:name]}]").value
          end

          expect(page_form_values.include?(@template_content)).to eq true
        end
      end

      context 'when navigated to new form without template params' do
        it 'does not prefill fields with cached template data' do
          visit model_path
          click_link 'Source'

          model_attributes_for_template.each do |model_attribute|
            if model_attribute[:value].is_a?(Date)
              expect(page.find_field("#{form_object_name}[#{model_attribute[:name]}]").value).not_to eq model_attribute[:value].to_date.strftime('%Y-%m-%d')
            else
              expect(page.find_field("#{form_object_name}[#{model_attribute[:name]}]").value).not_to eq model_attribute[:value]
            end
          end
        end
      end
    end
  end
end
