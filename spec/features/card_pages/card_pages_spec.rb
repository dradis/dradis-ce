require 'rails_helper'

describe 'Card pages:' do
  subject { page }

  it 'should require authenticated users' do
    project = create(:project)
    @board = create(:board, project: project, node: project.methodology_library)
    Configuration.create(name: 'admin:password', value: 'rspec_pass')
    visit project_board_path(@board.project, @board)
    expect(current_path).to eq(login_path)
    expect(page).to have_content('Access denied.')
  end

  context 'as authenticated user' do
    let(:add_users) do
      @first_user  = create(:user)
      @second_user = create(:user)
    end

    before do
      login_to_project_as_user
      @board = create(:board, project: current_project, node: current_project.methodology_library)
      @list  = create(:list, board: @board)
    end

    describe 'when in new page' do
      let(:submit_form) { click_button 'Create Card' }

      describe 'submitting the form with valid information' do
        before do
          visit new_project_board_list_card_path(current_project, @board, @list)
          fill_in :card_name, with: 'New Card'
          fill_in :card_description, with: 'New Card Description'
        end

        it 'creates a new card in this list' do
          expect{submit_form}.to change{Card.count}.by(1)
          expect(page).to have_text('Task added.')
          expect(current_path).to eq(project_board_list_card_path(current_project, @board, @list, Card.last))
        end

        include_examples 'creates an Activity', :create, Card
      end

      describe 'submitting the form with invalid information' do
        before do
          visit new_project_board_list_card_path(current_project, @board, @list)
          fill_in :card_name, with: ''
        end

        it 'doesn\'t create a new card' do
          expect{submit_form}.not_to(change{Card.count})
        end

        it 'shows the form again with an error message' do
          submit_form
          expect(page).to have_text("can't be blank")
          expect(current_path).to eq(project_board_list_cards_path(current_project, @board, @list))
        end

        include_examples "doesn't create an Activity"
      end

      describe 'assigning users' do
        before do
          add_users
          visit new_project_board_list_card_path(current_project, @board, @list)
          fill_in :card_name, with: 'New Card'
        end

        it 'assigns selected users to the card' do
          check @first_user.name
          check @second_user.name

          submit_form

          expect(Card.last.assignees.count).to eq 2
        end
      end
    end

    describe 'when in edit page' do
      let(:submit_form) { click_button 'Update Card' }

      before do
        @card = create(:card, list: @list)
      end

      describe 'submitting the form with valid information' do
        before do
          visit edit_project_board_list_card_path(current_project, @board, @list, @card)
          fill_in :card_name, with: 'Edited Card'
          fill_in :card_description, with: 'Edited Card Description'
        end

        it 'updates the card' do
          expect do
            submit_form
            expect(page).to have_text('Task updated')
            expect(page).to have_text('Edited Card')
            expect(page).to have_text('Edited Card Description')
            expect(current_path).to eq(project_board_list_card_path(current_project, @board, @list, @card))
          end.not_to(change{ Card.count })
        end

        let(:model) { @card }
        include_examples 'creates an Activity', :update
      end

      describe 'submitting the form with invalid information' do
        before do
          visit edit_project_board_list_card_path(current_project, @board, @list, @card)
          fill_in :card_name, with: ''
        end

        it "doesn't update the card" do
          expect{submit_form}.not_to(change{ @card.reload.name })
        end

        it 'shows the form again with an error message' do
          submit_form
          expect(page).to have_text("can't be blank")
          expect(current_path).to eq(project_board_list_card_path(current_project, @board, @list, @card))
        end

        include_examples "doesn't create an Activity"
      end

      describe 'assigning users' do
        before do
          add_users
          @card.assignees = [@first_user]
          @card.save
          visit edit_project_board_list_card_path(current_project, @board, @list, @card)
        end

        it 'displays assigned checked and unassigned unchecked' do
          expect(page).to have_selector("input[type=checkbox][id=card_assignee_ids_#{@first_user.id}][checked=checked]")
          expect(page).to have_selector("input[type=checkbox][id=card_assignee_ids_#{@second_user.id}]:not(checked)")
        end

        it 'assigns selected and unassigns unselected' do
          uncheck @first_user.name
          check @second_user.name

          submit_form

          expect(page).not_to have_text(@first_user.name)
          expect(page).to have_text(@second_user.name)
        end
      end
    end

    describe 'when in show page' do
      before do
        @card = create(:card, list: @list)
        @card2 = create(:card, list: @list, previous_id: @card.id)
        @card3 = create(:card, list: @list, previous_id: @card2.id)
        create_activities
        create_comments
        visit project_board_list_card_path(current_project, @board, @list, @card)
      end

      let(:create_activities) { nil }
      let(:create_comments) { nil }

      let(:trackable) { @card }
      it_behaves_like 'a page with an activity feed'

      let(:commentable) { @card }
      it_behaves_like 'a page with a comments feed'

      let(:subscribable) { @card }
      it_behaves_like 'a page with subscribe/unsubscribe links'

      it 'has a link to edit card' do
        expect(page).to have_selector("a[href='#{edit_project_board_list_card_path(current_project, @board, @list, @card)}']")
      end

      it 'has a link to delete card' do
        expect(page).to have_selector("a[href='#{project_board_list_card_path(current_project, @board, @list, @card)}'][data-method='delete']")
      end

      describe "clicking 'delete'" do
        before { PaperTrail.enabled = true }
        after  { PaperTrail.enabled = false }

        let(:submit_form) { click_link 'Delete' }

        it 'deletes the card' do
          id = @card.id
          submit_form
          expect(Card.exists?(id)).to be false
          expect(current_path).to eq project_board_path(current_project, @board)
          expect(page).to have_text 'Task deleted'
        end

        it 'adjusts the list' do
          id = @card2.id
          submit_form
          expect(Card.find(id).previous_id).to be_nil
        end

        let(:model) { @card }
        let(:submit_form) { within('.note-text-inner') { click_link 'Delete' } }
        let(:trackable) { @card }

        include_examples 'creates an Activity', :destroy
      end
    end
  end
end
