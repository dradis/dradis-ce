shared_examples 'an index table toolbar' do
  describe 'when clicking \'Select All\'' do
    before do
      find('.js-items-table-select-all').click
    end

    it 'selects all items' do
      all('input[type=checkbox].js-multicheck').each do |el|
        expect(el['checked']).to be true
      end
    end

    it 'shows the item actions bar' do
      expect(find('.js-items-table-actions')).to be_visible
    end
  end

  describe 'when clicking items' do
    it 'displays action buttons if 1 item is clicked' do
      expect(find('.js-items-table-actions', visible: :all)).to_not be_visible
      first('input[type=checkbox].js-multicheck').click
      expect(find('.js-items-table-actions')).to be_visible
    end

    # context 'deleting with background job' do
    #   before do
    #     ActiveJob::Base.queue_adapter = :test
    #   end
    #
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
    #     expect(page).to have_current_path(node_path(@node, tab: 'notes-tab'))
    #     expect(find('.js-items-table-actions', visible: :all)).to_not be_visible
    #     expect(find('#modal-console', visible: :all)).to_not be_visible
    #   end
    # end

    context 'deleting with inline job' do
      it 'resets toolbar after deleting items' do
        first('input[type=checkbox].js-multicheck').click
        expect(page).to have_css('.js-items-table-actions')
        find('.js-items-table-delete').click
        expect(page).to_not have_css('.js-items-table-actions')
        expect(page).to have_text(/deleted/)
      end
    end
  end

  describe 'when deleting multiple items' do
    context 'without filters' do
      before do
        ActiveJob::Base.queue_adapter = :test
      end

      it 'enqueues a background job with the items to delete' do
        expect {
          find('#select-all').click
          find('.js-items-table-delete').click
          find('#modal-console', visible: true) # wait for the response
        }.to have_enqueued_job(MultiDestroyJob).with(
          ids: items.map(&:id),
          klass: items.first.class.to_s,
          author_email: @logged_in_as.email,
          uid: 1
        )
      end
    end

    context 'with filters' do
      it 'does not delete filtered items' do
        filter = first('td:nth-child(2)').text
        find('.js-table-filter').set(filter)
        expect(
          all(
            'input[type=checkbox].js-multicheck',
            visible: true
          ).size
        ).to eq 1
        find('#select-all').click
        find('.js-items-table-delete').click
        expect(page).to have_text(/deleted/)
        klass = items.last.class
        expect(klass.pluck(:id).include?(items.first.id)).to be false
        expect(klass.count).to be items.size - 1
      end
    end
  end

end
