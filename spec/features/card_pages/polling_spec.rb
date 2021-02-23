require 'rails_helper'

describe 'card pages', js: true do
  include ActivityMacros

  subject { page }

  shared_examples 'a card page with poller' do

    describe 'when someone else adds a card' do
      before do
        @new_card = create(:card, list: @card.list)
        create(:activity, action: :create, trackable: @new_card, user: @other_user, project: current_project)
        call_poller
      end

      it 'adds a link' do
        expect(page).to have_selector "#card_#{@new_card.id}_link"
      end
    end

    describe 'when someone else updates that card' do
      before do
        @card.update(name: 'whatever')
        create(:activity, action: :update, trackable: @card, user: @other_user, project: current_project)
        call_poller
      end

      it 'updates card on show and warns on edit' do
        if action == :edit
          expect(page).to have_selector '#card-updated-alert'
        elsif action == :show
          expect(page).to have_selector '#js-card h4', text: /whatever/i
        end
      end
    end

    describe 'when someone else updates another card' do
      before do
        @other_card.update(name: 'updated card')
        create(:activity, action: :update, trackable: @other_card, user: @other_user, project: current_project)
        call_poller
      end

      it 'updates the link' do
        within "#card_#{@other_card.id}_link" do
          expect(page).to have_text 'updated card'
        end
      end
    end

    describe 'when someone else deletes that card' do
      before do
        @card.destroy
        create(:activity, action: :destroy, trackable: @card, user: @other_user, project: current_project)
        call_poller
      end

      it 'displays a warning' do
        expect(page).to have_selector '#card-deleted-alert'
      end
    end

    describe 'when someone else deletes another card' do
      before do
        @other_card.destroy
        create(:activity, action: :destroy, trackable: @other_card, user: @other_user, project: current_project)
        call_poller
      end

      it 'removes the link' do
        expect(page).not_to have_selector "#card_#{@other_card.id}_link"
      end
    end

    describe 'when someone else moves that card' do
      before do
        @card.update(list_id: @other_list.id)
        create(:activity, action: :update, trackable: @card, user: @other_user, project: current_project)
        call_poller
      end

      it 'updates card on show and warns on edit' do
        if action == :edit
          expect(page).to have_selector '#card-updated-alert'
        elsif action == :show
          expect(page).to\
            have_selector(
              'ol.breadcrumb li:nth-child(2) a',
              text: "#{@board.name} - #{@other_list.name}"
            )
        end
      end
    end

    describe 'when someone else moves (out) another card' do
      before do
        @other_card.update(list_id: @other_list.id)
        create(:activity, action: :update, trackable: @other_card, user: @other_user, project: current_project)
        call_poller
      end

      it 'removes the link' do
        expect(page).not_to have_selector "#card_#{@other_card.id}_link"
      end
    end

    describe 'when someone else moves (in) another card' do
      before do
        @moved_card = create(:card, list: @list, previous_id: @other_card.id)
        create(:activity, action: :update, trackable: @moved_card, user: @other_user, project: current_project)
        call_poller
      end

      it 'adds the link' do
        expect(page).to have_selector "#card_#{@moved_card.id}_link"
      end
    end

    describe 'and someone updates then deletes that card' do
      before do
        @card.update(name: 'whatever')
        create(:activity, action: :update, trackable: @card, user: @other_user, project: current_project)
        @card.destroy
        create(:activity, action: :destroy, trackable: @card, user: @other_user, project: current_project)
        call_poller
      end

      it 'displays a warning' do
        # Make sure the 'update' actions pointing to a no-longer-existent
        # Card don't crash the poller!
        should have_selector '#card-deleted-alert'
      end
    end

    describe 'when someone else deletes that list' do
      before do
        @list.destroy
        create(:activity, action: :destroy, trackable: @list, user: @other_user, project: current_project)
        call_poller
      end

      it 'displays a warning' do
        expect(page).to have_selector '#list-deleted-alert'
      end
    end

    describe 'when someone else deletes that board' do
      before do
        @board.destroy
        create(:activity, action: :destroy, trackable: @board, user: @other_user, project: current_project)
        call_poller
      end

      it 'displays a warning' do
        expect(page).to have_selector '#board-deleted-alert'
      end
    end
  end

  before do
    PaperTrail.enabled = true

    login_to_project_as_user
    @other_user = create(:user)
    @board      = create(:board, project: current_project)
    @list       = create(:list, board: @board)
    @other_list = create(:list, board: @board)
    @card       = create(:card, list: @list)
    @other_card = create(:card, list: @list, previous_id: @card.id)
  end

  after { PaperTrail.enabled = false }

  describe 'when I am viewing a card' do
    before { visit project_board_list_card_path(current_project, @board, @list, @card) }
    let(:action) { :show }
    it_behaves_like 'a card page with poller'
  end

  describe 'when I am editing a card' do
    before { visit edit_project_board_list_card_path(current_project, @board, @list, @card) }
    let(:action) { :edit }
    it_behaves_like 'a card page with poller'
  end
end
