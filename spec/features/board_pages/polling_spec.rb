require 'rails_helper'

describe 'board pages', js: true do
  include ActivityMacros

  subject { page }

  before do
    login_to_project_as_user
    @other_user = create(:user)
    @board      = create(:board, project: current_project, node: current_project.methodology_library)
    @list       = create(:list, board: @board)
    @other_list = create(:list, board: @board, previous_id: @list.id)
    @card       = create(:card, list: @list)
  end

  describe 'when I am viewing a board' do
    before { visit project_board_path(current_project, @board) }

    it_behaves_like 'a board page with poller'
  end

  describe 'when I am viewing the boards index' do
    before { visit project_boards_path(current_project) }

    describe 'when someone else updates a board' do
      before do
        @board.update(name: 'whatever')
        create(:activity, action: :update, trackable: @board, user: @other_user, project: current_project)
        call_poller
      end

      it 'updates that board name' do
        expect(page).to have_text 'whatever'
      end
    end

    describe 'when someone else removes a board' do
      before do
        PaperTrail.enabled = true

        @board.destroy
        create(:activity, action: :destroy, trackable: @board, user: @other_user, project: current_project)
        call_poller
      end

      after { PaperTrail.enabled = false }

      it 'removes that board' do
        expect(page).not_to \
          have_selector "li.board-list-item[data-board-id='#{@board.id}']"
      end
    end

    describe 'when someone else creates a board' do
      before do
        @other_board = create(:board, project: current_project, node: current_project.methodology_library)
        create(:activity, action: :create, trackable: @other_board, user: @other_user, project: current_project)
        call_poller
      end

      it 'adds the board' do
        expect(page).to \
          have_selector 'span.board-tile-details-name', text: @board.name
      end
    end
  end
end
