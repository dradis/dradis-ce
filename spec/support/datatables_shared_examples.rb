# let(:default_columns) { ['Title', 'Created', ...] }
# let(:hidden_columns) { ['Description', 'Extra', ...] }
# let(:filter) { { keyword:'keyword', number_of_rows: 1 } }
shared_examples 'a DataTable' do
  describe 'column visibility', js: true do
    it 'displays default columns on load' do
      within '.dataTables_wrapper thead tr' do
        default_columns.each do |column|
          expect(page).to have_text(column)
        end
      end
    end

    it 'does not show hidden columns on load' do
      within '.dataTables_wrapper thead tr' do
        hidden_columns.each do |column|
          expect(page).to_not have_text(column)
        end
      end
    end

    it 'can toggle column visibility by clicking on colvis button' do
      if hidden_columns.present?
        within '.dt-buttons.btn-group' do
          page.find('.buttons-colvis').click

          within '.dt-button-collection' do
            click_link hidden_columns[0]
          end
        end

        within '.dataTables_wrapper thead tr' do
          expect(page).to have_text(hidden_columns[0])
        end
      end
    end
  end

  describe 'delete button', js: true do
    before do
      unless page.has_css?('[data-table-destroy-url]')
        # Skip this spec if table doesn't support bulk delete
        skip
      end
    end

    it 'is hidden by default' do
      within '.dt-buttons.btn-group' do
        expect(page).to_not have_button('Delete')
      end
    end

    it 'is visible when row checkbox is selected' do
      within '.dataTables_wrapper' do
        page.find('td.select-checkbox', match: :first).click
        expect(page).to have_button('Delete')
      end
    end

    it 'is hidden again after a row checkbox is unselected' do
      within '.dataTables_wrapper' do
        page.find('td.select-checkbox', match: :first).click
        page.find('td.select-checkbox', match: :first).click

        expect(page).to_not have_button('Delete')
      end
    end

    it 'can delete a selected item' do
      within '.dataTables_wrapper' do
        original_row_count = page.all('tbody tr').count
        page.find('td.select-checkbox', match: :first).click

        page.accept_confirm do
          click_button('Delete')
        end

        # Wait for ajax
        page.find('.alert')

        expect(page.all('tbody tr').count).to eq(original_row_count - 1)
        expect(page).to have_text(/deleted/)
      end
    end
  end

  describe 'tagging', js: true do
    before do
      unless page.has_css?('[data-tags]')
        # Skip this spec if table doesn't support tagging
        skip
      end
    end

    it 'shows the tag button when an item is selected' do
      within '.dataTables_wrapper' do
        page.find('td.select-checkbox', match: :first).click
        expect(page).to have_button('Tag')
      end
    end

    it 'shows the available tags' do
      page.find('td.select-checkbox', match: :first).click

      within '.dt-buttons.btn-group' do
        click_button('Tag')

        within '.dt-button-collection' do
          @tags.each do |tag|
            expect(page).to have_link(tag.display_name)
          end
        end
      end
    end

    it 'tags the selected issue' do
      page.find('td.select-checkbox', match: :first).click

      within '.dt-buttons.btn-group' do
        click_button('Tag')

        within '.dt-button-collection' do
          click_link(@tags.first.display_name)
        end
      end

      # Wait for the spinner to disappear
      expect(page).to_not have_css('[data-behavior=spinner]')
      expect(@issue.reload.tags).to include(@tags.first)
    end
  end

  it 'can filter rows', js: true do
    within '.dataTables_filter' do
      search_input = page.find('input[type=search]')
      search_input.set(filter[:keyword])
    end

    within '.dataTable' do
      expect(all('tbody tr').count).to eq(filter[:filter_count])
    end
  end
end

# let(:new_content) { "#[Title]#\nTitle\n\n#[New Field]#\nNew Field Value" }
# let(:old_content) { "#[Title]#\nTitle" }
# let(:resource) { Issue.take }
# let(:resource_attribute) { 'text' }
shared_examples 'a DataTable with Dynamic Columns' do
  let(:hide_default_columns) do
    within '.dt-buttons.btn-group' do
      page.find('.buttons-colvis').click

      within '.dt-button-collection' do
        click_link 'Created'
        click_link 'Updated'
      end
    end
  end

  let(:update_resource_with_new_content) do
    attributes = Hash[resource_attribute, new_content]
    resource.update(attributes)
  end

  let(:update_resource_with_old_content) do
    attributes = Hash[resource_attribute, old_content]
    resource.update(attributes)
  end

  context 'when new columns are added', js: true do
    it 'persists column state' do
      hide_default_columns
      update_resource_with_new_content

      # Refresh
      visit current_url

      within '.dataTables_wrapper thead tr' do
        expect(page).to_not have_text('Created')
        expect(page).to_not have_text('Updated')
        expect(page).to have_text('New Field')
      end
    end
  end

  context 'when columns are removed', js: true do
    it 'persists column state' do
      hide_default_columns
      update_resource_with_new_content

      # Refresh
      visit current_url

      within '.dataTables_wrapper thead tr' do
        expect(page).to have_text('New Field')
      end

      update_resource_with_old_content

      # Refresh
      visit current_url

      within '.dataTables_wrapper thead tr' do
        expect(page).to_not have_text('Created')
        expect(page).to_not have_text('Updated')
        expect(page).to_not have_text('New Field')
      end
    end
  end
end
