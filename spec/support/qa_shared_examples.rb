shared_examples 'qa pages' do |item_type|

  describe 'index page' do
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
      click_link 'Edit', match: :first

      expect(current_path).to eq polymorphic_path([:edit, current_project, records.first])

      click_button "Update #{item_type.to_s.titleize}"

      expect(current_path).to eq polymorphic_path([current_project, :qa, item_type.to_s.pluralize.to_sym])
      expect(page).to have_selector('.alert-success', text: "#{item_type.to_s.humanize} updated.")
    end
  end

  describe 'show page' do
    before do
      visit polymorphic_path([current_project, :qa, records.first])
    end

    it 'shows the record\'s content' do
      expect(page).to have_content(records.first.title)
    end

    it 'redirects the user back after updating the record' do
      within '.note-text-inner' do
        click_link 'Edit'
      end

      expect(current_path).to eq polymorphic_path([:edit, current_project, records.first])

      click_button "Update #{item_type.to_s.titleize}"

      expect(current_path).to eq polymorphic_path([current_project, :qa, records.first])
      expect(page).to have_selector('.alert-success', text: "#{item_type.to_s.humanize} updated.")
    end

    it 'updates the state to draft' do
      click_button 'Draft'

      expect(current_path).to eq polymorphic_path([current_project, :qa, item_type.to_s.pluralize.to_sym])
      expect(page).to have_selector('.alert-success', text: 'State updated successfully.')
      expect(records.first.reload.draft?).to eq true
    end

    it 'updates the state to published' do
      click_button 'Published'

      expect(current_path).to eq polymorphic_path([current_project, :qa, item_type.to_s.pluralize.to_sym])
      expect(page).to have_selector('.alert-success', text: 'State updated successfully.')
      expect(records.first.reload.published?).to eq true
    end
  end
end
