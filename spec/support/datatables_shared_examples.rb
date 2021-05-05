#  let(:default_columns) { ['Title', 'Created', ...] }
#  let(:hidden_columns) { ['Description', 'Extra', ...] }
#  let(:filter) { { keyword:'keyword', number_of_rows: 1 } }
#
#
shared_examples 'a DataTable' do |item_type|
  describe 'column visibility', js: true do
    it 'displays default columns on load' do
      within '[data-behavior~=datatable]' do
        within 'thead tr' do
          default_columns.each do |column|
            expect(page).to have_text(column)
          end
        end
      end
    end

    it 'does not show hidden columns on load' do
      within '[data-behavior~=datatable]' do
        within 'thead tr' do
          hidden_columns.each do |column|
            expect(page).to_not have_text(column)
          end
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

      within '[data-behavior~=datatable]' do
        within 'thead tr' do
          expect(page).to have_text(hidden_columns[0])
        end
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
