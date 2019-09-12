# This shared shared_example needs the folowing *let* variables:
# - board:
#   how to create a board (project level or node level)
# - boards_path:
#   the path to boards index
#   (the page with a CTA to create a new board)
# - board_path:
#   the path to board show page
shared_examples 'managing boards' do
  let(:model) { board }

  let(:create_link) do
    'a.board-new.js-board-modal'
  end

  let(:delete_link) do
    "a[href='#{project_board_path(current_project, board)}'][data-method='delete']"
  end

  describe 'when there is no board' do
    let(:board) { nil }

    it 'contains a link to add a new board' do
      visit boards_path
      expect(page).to have_selector create_link
    end
  end

  it 'contains a link to rename the board' do
    board
    visit boards_path

    edit_link = "a[href='#modal-board-edit-#{board.id}']"
    expect(page).to have_selector(edit_link, visible: false)
  end

  it 'contains a link to delete each board' do
    board
    visit boards_path

    expect(page).to have_selector(delete_link)
  end

  describe 'deleting a board' do
    let(:submit_form) do
      page.find(delete_link).click
      expect(page).to have_text 'Methodology deleted'
    end

    before do
      board
      visit boards_path
      expect(page).to have_selector(delete_link)
    end

    it 'deletes the board' do
      id = board.id
      submit_form

      expect(Board.exists?(id)).to be false
      expect(page).to have_current_path(project_boards_path(current_project))
    end

    include_examples 'creates an Activity', :destroy
  end

  describe 'updating a board', js: true do
    let(:submit_form) { click_button 'Update methodology' }

    let(:modal_selector) { "#modal-board-edit-#{@b.id}" }

    before do
      @b = board
      visit boards_path
      find("a[href='#{project_board_path(current_project, @b)}']").hover
      find("a[href='#{modal_selector}']").click
      expect(page).to have_selector(modal_selector, visible: true)
    end

    describe 'submitting the form with valid information' do
      before do
        within modal_selector do
          fill_in :board_name, with: 'New Board Name'
        end
      end

      it 'renames the board' do
        expect do
          submit_form
          expect(page).to have_text('Methodology renamed')
          expect(page).to have_text('New Board Name')
          expect(page).to have_current_path board_path
        end.not_to(change{Board.count})
      end

      include_examples 'creates an Activity', :update, @b
    end

    describe 'submitting the form with invalid information' do
      before do
        within modal_selector do
          fill_in :board_name, with: ''
        end
      end

      it "doesn't rename the board" do
        old_name = @b.name
        submit_form
        expect(old_name).to eq @b.reload.name
        expect(page).to have_text("can't be blank")
      end

      include_examples "doesn't create an Activity"
    end
  end
end

shared_examples 'a board page with poller' do
  describe 'when someone else updates that board' do
    before do
      @board.update_attributes(name: 'whatever new board name')
      create(:activity, action: :update, trackable: @board, user: @other_user)
      call_poller
      wait_for_ajax
    end

    it 'updates the board' do
      expect(page).to have_text(/whatever new board name/i)
    end
  end

  describe 'when someone else deletes that board' do
    before do
      PaperTrail.enabled = true

      @board.destroy
      create(:activity, action: :destroy, trackable: @board, user: @other_user)
      call_poller
    end

    after { PaperTrail.enabled = false }

    it 'displays a warning' do
      expect(page).to have_selector '#board-deleted-alert'
    end
  end

  describe 'and someone updates then deletes that board' do
    before do
      PaperTrail.enabled = true

      @board.update_attributes(name: 'whatever')
      create(:activity, action: :update, trackable: @board, user: @other_user)
      @board.destroy
      create(:activity, action: :destroy, trackable: @board, user: @other_user)
      call_poller
    end

    after { PaperTrail.enabled = false }

    it 'displays a warning' do
      # Make sure the 'update' actions pointing to a no-longer-existent
      # Board don't crash the poller!
      expect(page).to have_selector '#board-deleted-alert'
    end
  end

  describe 'when someone else adds a list to that board' do
    before do
      @new_list = create(:list, board: @board, previous_id: @other_list.id)
      create(:activity, action: :create, trackable: @new_list, user: @other_user)
      call_poller
    end

    it 'adds the list' do
      expect(page).to have_selector 'h4', text: "#{@new_list.name}\n0"
    end
  end

  describe 'when someone else moves a list on that board' do
    before do
      @other_list.update_attributes(previous_id: nil)
      @list.update_attributes(previous_id: @other_list.id)
      create(:activity, action: :update, trackable: @other_list, user: @other_user)
      call_poller
      wait_for_ajax
    end

    it 'moves the list' do
      expect(page.find("ul.board li.list[data-list-id='#{@other_list.id}'] h4"))\
        .to have_text(@other_list.name)
      expect(page.find("ul.board li.list[data-list-id='#{@list.id}'] h4"))\
        .to have_text(@list.name)
    end
  end

  describe 'when someone else deletes a list on that board' do
    before do
      @other_list.destroy
      create(:activity, action: :destroy, trackable: @other_list, user: @other_user)
      call_poller
    end

    it 'deletes the list' do
      expect(page).not_to have_selector "li.list[data-list-id='#{@other_list.id}']"
    end
  end

  describe 'when someone updates a list on that board' do
    before do
      @other_list.update_attributes(name: 'updated list')
      create(:activity, action: :update, trackable: @other_list, user: @other_user)
      call_poller
    end

    it 'updates the list' do
      expect(page).to have_selector('h4', text: 'updated list')
    end
  end

  describe 'when someone adds a card on that board' do
    before do
      @new_card = create(:card, list: @list, previous_id: @card.id)
      create(:activity, action: :create, trackable: @new_card, user: @other_user)
      call_poller
    end

    it 'adds the card' do
      expect { page.find('div.card-title', text: @new_card.name) }.not_to \
        raise_error
    end
  end

  describe 'when someone updates a card on that board' do
    before do
      @card.update_attributes(name: 'updated card')
      create(:activity, action: :update, trackable: @card, user: @other_user)
      call_poller
    end

    it 'updates the card' do
      expect(page).to have_selector('div.card-title', text: 'updated card')
    end
  end

  describe 'when someone deletes a card on that board' do
    before do
      PaperTrail.enabled = true

      @card.destroy
      create(:activity, action: :destroy, trackable: @card, user: @other_user)
      call_poller
    end

    after { PaperTrail.enabled = false }

    it 'removes the card' do
      expect(page).not_to have_selector "li.card[data-card-id='#{@card.id}']"
    end
  end

  describe 'when someone moves a card on that board' do
    before do
      @card.update_attributes(list_id: @other_list.id)
      create(:activity, action: :update, trackable: @card, user: @other_user)
      call_poller
    end

    it 'moves the card' do
      expect(page).to\
        have_selector(
          "li.list[data-list-id='#{@other_list.id}'] div.card-title",
          text: @card.name
        )
    end
  end
end
