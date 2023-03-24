shared_examples 'qa pages' do |item_type|

  describe 'index page', js: true do
    MODEL = item_type.to_s.classify.constantize
    STATES = ['Draft', 'Published']

    before do
      visit polymorphic_path([current_project, :qa, item_type.to_s.pluralize.to_sym])
    end

    it 'lists all the records that are ready for review' do
      records.each do |record|
        record_qa_path = polymorphic_path([current_project, :qa, record])
        expect(page).to have_link(record.title, href: record_qa_path)
      end
    end

    it 'redirects the user back after updating the record' do
      find('.dataTable tbody tr:first-of-type').hover
      click_link 'Edit'

      expect(current_path).to eq polymorphic_path([:edit, current_project, :qa, records.first])

      click_button "Update #{item_type.to_s.titleize}"

      expect(current_path).to eq polymorphic_path([current_project, :qa, item_type.to_s.pluralize.to_sym])
      expect(page).to have_selector('.alert-success', text: "#{item_type.to_s.humanize} updated.")
    end

    context 'bulk update' do
      it 'is hidden by default' do
        within '.dt-buttons.btn-group' do
          expect(page).to_not have_button('State')
        end
      end

      it 'is visible when row checkbox is selected' do
        within '.dataTables_wrapper' do
          page.find('td.select-checkbox', match: :first).click
          expect(page).to have_button('State')
        end
      end

      it 'is hidden again after a row checkbox is unselected' do
        within '.dataTables_wrapper' do
          page.find('td.select-checkbox', match: :first).click
          page.find('td.select-checkbox', match: :first).click

          expect(page).to_not have_button('State')
        end
      end

      it 'updates the list of records with the state' do
        STATES.each do |state|
          record = MODEL.where(state: 'ready_for_review').first
          visit polymorphic_path([current_project, :qa, item_type.to_s.pluralize.to_sym])

          within '.dataTables_wrapper' do
            @original_row_count = page.all('tbody tr').count
            page.find('td.select-checkbox', match: :first).click

            click_button('State')
            expect { click_link state }.to have_enqueued_job(ActivityTrackingJob).with(
              action: 'update_state',
              project_id: current_project.id,
              trackable_id: record.id,
              trackable_type: record.class.to_s,
              user_id: @logged_in_as.id
            )

            expect(current_path).to eq polymorphic_path([current_project, :qa, item_type.to_s.pluralize.to_sym])
            expect(page.all('tbody tr').count).to eq(@original_row_count - 1)
            expect(page).to have_selector('.alert-success', text: 'State updated successfully.')
            expect(record.reload.state).to eq state.downcase.gsub(' ', '_')
          end
        end
      end
    end
  end

  describe 'show page' do
    it 'shows the record\'s content' do
      visit polymorphic_path([current_project, :qa, records.first])
      expect(page).to have_content(records.first.title)
    end

    it 'updates the state' do
      STATES.each do |state|
        record = MODEL.where(state: 'ready_for_review').first
        visit polymorphic_path([current_project, :qa, record])

        expect { click_button state }.to have_enqueued_job(ActivityTrackingJob).with(
          action: 'update_state',
          project_id: current_project.id,
          trackable_id: record.id,
          trackable_type: record.class.to_s,
          user_id: @logged_in_as.id
        )

        expect(current_path).to eq polymorphic_path([current_project, :qa, item_type.to_s.pluralize.to_sym])
        expect(page).to have_selector('.alert-success', text: 'State updated successfully.')
        expect(record.reload.state).to eq state.downcase.gsub(' ', '_')
      end
    end
  end

  describe 'edit page' do
    before do
      visit polymorphic_path([current_project, :qa, records.first])

      within '.note-text-inner' do
        click_link 'Edit'
      end
    end

    it 'redirects the user back after updating the record' do
      expect(current_path).to eq polymorphic_path([:edit, current_project, :qa, records.first])

      click_button "Update #{item_type.to_s.titleize}"

      expect(current_path).to eq polymorphic_path([current_project, :qa, records.first])
      expect(page).to have_selector('.alert-success', text: "#{item_type.to_s.humanize} updated.")
    end

    it 'redirects the user back after cancelling' do
      expect(current_path).to eq polymorphic_path([:edit, current_project, :qa, records.first])

      click_link 'Cancel'

      expect(current_path).to eq polymorphic_path([current_project, :qa, records.first])
    end
  end
end
