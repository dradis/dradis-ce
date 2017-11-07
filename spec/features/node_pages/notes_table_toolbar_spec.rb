require 'rails_helper'

describe 'node pages' do
  describe '#show notes table toolbar', js: true do
    subject { page }

    before do
      login_to_project_as_user

      node   = create(:node)
      @note1 = create(:note, node: node, text: "#[Title]#\r\ntest1\r\n\r\n#[Description]#\r\nnone1\r\n")
      @note2 = create(:note, node: node, text: "#[Title]#\r\ntest2\r\n\r\n#[Description]#\r\nnone2\r\n")

      visit node_path(node, tab: 'notes-tab')
    end

    context 'when Select All is clicked' do
      before do
        find('.js-index-table-select-all').click
      end

      it 'selects all notes' do
        all('input[type=checkbox].js-multicheck').each do |el|
          expect(el['checked']).to be true
        end
      end

      it 'shows the note actions bar' do
        expect(find('.js-index-table-actions')).to be_visible
      end
    end

    context 'when clicking notes' do
      it 'displays action buttons (delete button) if 1 note is clicked' do
        expect(find('.js-index-table-actions', visible: :all)).to_not be_visible
        check "note_#{@note1.id}"
        expect(find('.js-index-table-actions')).to be_visible
      end

      it 'resets toolbar after deleting notes' do
        check "note_#{@note1.id}"
        expect(page).to have_css('.js-index-table-actions')
        find('.js-index-table-delete').click
        expect(find('#modal-console')).to be_visible
        find('#main-menu').trigger('click') # anywhere outside the modal
        expect(find('.js-index-table-actions', visible: :all)).to_not be_visible
        expect(find('#modal-console', visible: :all)).to_not be_visible
      end
    end

    describe 'when deleting multiple notes' do
      before do
        ActiveJob::Base.queue_adapter = :test
      end

      context 'without filters' do
        it 'enqueues a background job with the notes' do
          expect {
            find('#select-all').click
            find('.js-index-table-delete').click
            save_and_open_screenshot
          }.to have_enqueued_job(DestroyJob).with(
            items: [ @note1, @note2 ],
            author_email: @logged_in_as.email,
            uid: 1
          )
        end
      end

      context 'with filters' do
        it 'does not delete filtered notes' do
          find('.js-table-filter').set('1')
          expect(page).to have_selector("#note_#{@note2.id}", visible: false)

          expect {
            find('#select-all').click
            find('.js-index-table-delete').click
            save_and_open_screenshot
          }.to have_enqueued_job(DestroyJob).with(
            items: [ @note1 ],
            author_email: @logged_in_as.email,
            uid: 1
          )
        end
      end
    end
  end
end
