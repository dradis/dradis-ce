shared_examples 'qa pages' do |item_type|

  describe 'index page', js: true do
    before do
      @records = create_list(item_type, 10, state: :ready_for_review)
      visit polymorphic_path([current_project, :qa, item_type.to_s.pluralize.to_sym])
    end

    it 'lists all the records that are ready for review' do
      @records.each do |record|
        expect(page).to have_text(record.title)
      end
    end

    context 'bulk update' do
      it 'is hidden by default' do
        within '.dt-buttons.btn-group' do
          expect(page).to_not have_button('Update State')
        end
      end

      it 'is visible when row checkbox is selected' do
        within '.dataTables_wrapper' do
          page.find('td.select-checkbox', match: :first).click
          expect(page).to have_button('Update State')
        end
      end

      it 'is hidden again after a row checkbox is unselected' do
        within '.dataTables_wrapper' do
          page.find('td.select-checkbox', match: :first).click
          page.find('td.select-checkbox', match: :first).click

          expect(page).to_not have_button('Update State')
        end
      end

      it 'updates the list of records with the state' do
        within '.dataTables_wrapper' do
          @original_row_count = page.all('tbody tr').count
          page.find('td.select-checkbox', match: :first).click

          click_button('Update State')
          click_link('Published')
        end

        page.find('.alert')

        expect(page.all('tbody tr').count).to eq(@original_row_count - 1)
        expect(page).to have_text(/Successfully/)
      end
    end
  end

end
