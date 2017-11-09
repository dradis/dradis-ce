require 'rails_helper'

describe 'node pages' do
  describe '#show notes table toolbar', js: true do
    subject { page }

    before do
      login_to_project_as_user

      @node  = create(:node)
      @notes = []
      (Note::MAX_DELETED_INLINE + 1).times do |i|
        @notes << create(:note, node: @node, text: "#[Title]#\r\ntest#{i}\r\n\r\n#[Description]#\r\nnote#{i}\r\n")
      end

      visit node_path(@node, tab: 'notes-tab')
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

    describe 'when clicking notes' do
      it 'displays action buttons (delete button) if 1 note is clicked' do
        expect(find('.js-index-table-actions', visible: :all)).to_not be_visible
        check "checkbox_note_#{@notes[0].id}"
        expect(find('.js-index-table-actions')).to be_visible
      end

      # context 'deleting with background job' do
      #   before do
      #     ActiveJob::Base.queue_adapter = :test
      #   end
      #
      #   it 'resets toolbar after deleting notes' do
      #     @notes.each do |note|
      #       check "checkbox_note_#{note.id}"
      #     end
      #
      #     expect(page).to have_css('.js-index-table-actions')
      #     find('.js-index-table-delete').click
      #     expect(find('#modal-console')).to be_visible
      #
      #     # closes modal reloads page
      #     find('div.modal-backdrop.in').click
      #
      #     expect(page).to have_current_path(node_path(@node, tab: 'notes-tab'))
      #     expect(find('.js-index-table-actions', visible: :all)).to_not be_visible
      #     expect(find('#modal-console', visible: :all)).to_not be_visible
      #   end
      # end

      context 'deleting with inline job' do
        it 'resets toolbar after deleting notes' do
          check "checkbox_note_#{@notes[0].id}"
          expect(page).to have_css('.js-index-table-actions')
          find('.js-index-table-delete').click
          expect(page).to_not have_css('.js-index-table-actions')
          expect(Note.exists?(@notes[0].id)).to be false
        end
      end
    end

    describe 'when deleting multiple notes' do
      context 'without filters' do
        before do
          ActiveJob::Base.queue_adapter = :test
        end

        it 'enqueues a background job with the notes' do
          expect {
            find('#select-all').click
            find('.js-index-table-delete').click
            find('#modal-console', visible: true) # wait for the response
          }.to have_enqueued_job(DestroyJob).with(
            items: @notes,
            author_email: @logged_in_as.email,
            uid: 1
          )
        end
      end

      context 'with filters' do
        it 'does not delete filtered notes' do
          find('.js-table-filter').set(@notes.last.title)
          @notes[0..-2].each do |note|
            expect(page).to have_selector("#checkbox_note_#{note.id}", visible: false)
          end
          find('#select-all').click
          find('.js-index-table-delete').click
          expect(page).to have_text 'Notes deleted'
          expect(Note.exists?(@notes.last.id)).to be false
          expect(Note.count).to be @notes.size - 1
        end
      end
    end
  end
end
