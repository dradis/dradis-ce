shared_examples 'an index table toolbar' do
  example 'clicking \'Select All\' works' do
    find('.js-items-table-select-all').click
    expect(page).to have_selector('input.js-multicheck:checked') # forces wait

    # it selects all items
    all('input[type=checkbox].js-multicheck').each do |el|
      expect(el['checked']).to eq 'true'
    end

    # it shows the item actions bar
    expect(find('.js-items-table-actions')).to be_visible
  end

  describe 'when clicking items' do
    it 'displays action buttons if 1 item is clicked' do
      expect(find('.js-items-table-actions', visible: :all)).to_not be_visible
      first('input[type=checkbox].js-multicheck').click
      expect(find('.js-items-table-actions')).to be_visible
    end

    # context 'deleting with background job' do
    #   it 'resets toolbar after deleting items' do
    #     @notes.each do |note|
    #       check "checkbox_note_#{note.id}"
    #     end
    #
    #     expect(page).to have_css('.js-items-table-actions')
    #     find('.js-items-table-delete').click
    #     expect(find('#modal-console')).to be_visible
    #
    #     # closes modal reloads page
    #     find('div.modal-backdrop.in').click
    #
    #     expect(page).to have_current_path(project_node_path(@node.project, @node, tab: 'notes-tab'))
    #     expect(find('.js-items-table-actions', visible: :all)).to_not be_visible
    #     expect(find('#modal-console', visible: :all)).to_not be_visible
    #   end
    # end

    context 'deleting with inline job' do
      it 'resets toolbar after deleting items' do
        first('input[type=checkbox].js-multicheck').click
        expect(page).to have_css('.js-items-table-actions')
        page.accept_confirm do
          find('.js-items-table-delete').click
        end
        expect(page).to_not have_css('.js-items-table-actions')
        expect(page).to have_text(/deleted/)
      end
    end
  end

  describe 'when deleting multiple items' do
    context 'without filters' do
      it 'enqueues a background job with the items to delete' do
        checkboxes = all('.js-multicheck')

        expect {
          find('#select-all').click
          expect(page).to have_selector('input.js-multicheck:checked') # wait
          page.accept_confirm { find('.js-items-table-delete').click }
          find('#modal-console', visible: true) # wait
        }.to have_enqueued_job(MultiDestroyJob).with(
          ids: checkboxes.map(&:value),
          project_id: current_project.id,
          klass: items.first.class.to_s,
          author_email: @logged_in_as.email,
          uid: 1
        )
      end
    end

    context 'with filters' do
      it 'does not delete filtered items' do
        to_delete = items.first
        find('.js-table-filter').set(to_delete.title)
        expect(
          all(
            'input[type=checkbox].js-multicheck',
            visible: true
          ).size
        ).to eq 1
        find('#select-all').click
        expect(page).to have_selector('input.js-multicheck:checked') # wait
        page.accept_confirm { find('.js-items-table-delete').click }
        expect(page).to have_text(/deleted/)
        klass = to_delete.class
        expect(klass.exists?(to_delete.id)).to be false
        expect(klass.count).to be items.size - 1
      end
    end
  end

end
