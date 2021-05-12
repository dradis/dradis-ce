#  let(:default_columns) { ['Title', 'Created', ...] }
#  let(:hidden_columns) { ['Description', 'Extra', ...] }
#  let(:filter) { { keyword:'keyword', number_of_rows: 1 } }
#
#
shared_examples 'a DataTable' do |item_type|
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

  describe 'delete button', js: true do
    before do
      if page.has_css?('[data-behavior~=destroy-url]')
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
