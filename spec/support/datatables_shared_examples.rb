#  let(:columns) { ['Title', 'Created', ...] }
#  let(:custom_columns) { ['Description', 'Extra', ...] }
#  let(:filter) { { keyword:'keyword', number_of_rows: 1 } }
#
#
shared_examples 'a DataTable' do |item_type|
  it 'displays table columns', js: true do
    within '.dataTables_wrapper thead tr' do
      columns.each do |column|
        expect(page).to have_text(column)
      end

      custom_columns.each do |column|
        expect(page).to have_text(column)
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
