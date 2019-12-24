require 'rails_helper'

describe 'Board recover', js: true do
  subject { page }

  describe 'when I delete a card' do
    before do
      PaperTrail.enabled = true

      login_to_project_as_user

      @board = create(:board, project: current_project, node: current_project.methodology_library)
      @list = create(:list, board: @board)
      @card = create(:card, list: @list)
      @next_card = create(:card, list: @list, previous_id: @card.id)
      visit(polymorphic_path([current_project, @board, @list, @card]))
    end

    after { PaperTrail.enabled = false }

    let(:submit_form) do
      accept_confirm { click_link 'Delete' }
      expect(page).to have_text 'Task deleted'
    end

    let(:model) { @card }

    include_examples 'deleted item is listed in Trash', :card
    include_examples 'recover deleted item', :card

    def version_link_xpath
      version_id = model.versions.last.id
      "//a[@href='#{recover_project_revision_path(current_project, id: version_id)}']"
    end

    it 'should be recovered as the first item of the list' do
      submit_form
      visit project_trash_path(current_project)
      accept_confirm { find(:xpath, version_link_xpath).click }
      expect(page).to have_text 'Card recovered'
      expect(@list.first_item).to eq(@card)
    end

    context "when the card's list is deleted" do
      before do
        submit_form
        @list.destroy

        visit project_trash_path(current_project)
        accept_confirm { find(:xpath, version_link_xpath).click }
        expect(page).to have_text 'Card recovered'
      end

      it "should be inside the board's Recovered list" do
        card = Card.find(@card.id)
        expect(card).not_to be_nil
        expect(card.list).to eq(@board.recovered_list)
      end
    end

    context "when the card's board is deleted" do
      before do
        submit_form
        @list.destroy
        @board.destroy

        visit project_trash_path(current_project)
        accept_confirm { find(:xpath, version_link_xpath).click }
        expect(page).to have_text 'Card recovered'
      end

      it "should be inside the project's Recovered board and list" do
        card = Card.find(@card.id)
        board = current_project.boards.find_by(name: 'Recovered')
        expect(card).not_to be_nil
        expect(card.board).to eq(board)
        expect(card.list).to eq(board.recovered_list)
      end
    end
  end
end
