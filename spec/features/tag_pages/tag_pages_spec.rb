require 'rails_helper'

describe 'Tag pages:' do
  subject { page }

  # context 'as authenticated user' do

  before do
    login_to_project_as_user
  end

  describe 'index page', js: true do
    before do
      tags = create_list(:tag, 3, :color)
      visit project_configurations_tags_path(current_project)
    end

    it 'shows a list of tags' do
      expect(page).to have_selector('.tag-row', count: 3)
    end

    it 'shows edit and delete links in the table' do
      expect(page).to have_selector('.tag-row a', text: 'Edit')
      expect(page).to have_selector('.tag-row a', text: 'Delete')
    end

    it 'redirects to new tag page when New Tag link is clicked' do
      click_link 'New Tag'
      expect(current_path).to eq(new_project_configurations_tag_path(current_project))
    end

    describe 'delete link' do
      let(:delete_link) do
        page.accept_confirm do
          find('.tag-row a', text: 'Delete', match: :first, visible: :all).click
        end
      end

      it 'deletes a tag' do
        delete_link
        expect(page).to have_selector('.tag-row', count: 2)
        expect(page).to have_text('Tag deleted.')
      end
    end
  end

  describe 'new page' do
    let(:submit_form) { click_button 'Save Tag' }

    before do
      visit new_project_configurations_tag_path(current_project)
    end

    context 'with valid attributes' do
      it 'creates a new tag' do
        fill_in :tag_form_name, with: 'Critical'
        fill_in :tag_form_color, with: '#000000'
        expect{ submit_form }.to change{ Tag.count }.by(1)
        expect(page).to have_text('Tag added.')
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new tag' do
        fill_in :tag_form_name, with: '!@#123'
        fill_in :tag_form_color, with: '#000000'
        expect{ submit_form }.to change{ Tag.count }.by(0)
      end
    end
  end

  describe 'edit page' do
    let(:tag) { create(:tag, :color) }
    let(:submit_form) { click_button 'Save Tag' }

    before do
      visit edit_project_configurations_tag_path(current_project, tag)
    end

    it 'prefills input with tag attributes' do
      expect(page).to have_selector("input[value='#{tag.display_name}']")
      expect(page).to have_selector("input[value='#{tag.color}']")
    end

    it 'updates tag when name is changed' do
      fill_in :tag_form_name, with: 'Default'
      fill_in :tag_form_color, with: '#000000'
      submit_form
      expect(Tag.last.display_name).to eq 'Default'
    end
  end

  #   describe 'when in new page' do
  #     let(:submit_form) { click_button 'Create Card' }

  #     describe 'submitting the form with valid information' do
  #       before do
  #         visit new_project_board_list_card_path(current_project, @board, @list)
  #         fill_in :card_name, with: 'New Card'
  #         fill_in :card_description, with: 'New Card Description'
  #       end

  #       it 'creates a new card in this list' do
  #         expect{submit_form}.to change{Card.count}.by(1)
  #         expect(page).to have_text('Task added.')
  #         expect(current_path).to eq(project_board_list_card_path(current_project, @board, @list, Card.last))
  #       end

  #       include_examples 'creates an Activity', :create, Card
  #     end

  #     describe 'submitting the form with invalid information' do
  #       before do
  #         visit new_project_board_list_card_path(current_project, @board, @list)
  #         fill_in :card_name, with: ''
  #       end

  #       it 'doesn\'t create a new card' do
  #         expect{submit_form}.not_to(change{Card.count})
  #       end

  #       it 'shows the form again with an error message' do
  #         submit_form
  #         expect(page).to have_text("can't be blank")
  #         expect(current_path).to eq(project_board_list_cards_path(current_project, @board, @list))
  #       end

  #       include_examples "doesn't create an Activity"
  #     end

  #     describe 'assigning users' do
  #       before do
  #         add_users
  #         visit new_project_board_list_card_path(current_project, @board, @list)
  #         fill_in :card_name, with: 'New Card'
  #       end

  #       it 'assigns selected users to the card' do
  #         check @first_user.name
  #         check @second_user.name

  #         submit_form

  #         expect(Card.last.assignees.count).to eq 2
  #       end
  #     end
  #   end

  #   describe 'when in edit page' do
  #     let(:submit_form) { click_button 'Update Card' }

  #     before do
  #       @card = create(:card, list: @list)
  #     end

  #     describe 'submitting the form with valid information' do
  #       before do
  #         visit edit_project_board_list_card_path(current_project, @board, @list, @card)
  #         fill_in :card_name, with: 'Edited Card'
  #         fill_in :card_description, with: 'Edited Card Description'
  #       end

  #       it 'updates the card' do
  #         expect do
  #           submit_form
  #           expect(page).to have_text('Task updated')
  #           expect(page).to have_text('Edited Card')
  #           expect(page).to have_text('Edited Card Description')
  #           expect(current_path).to eq(project_board_list_card_path(current_project, @board, @list, @card))
  #         end.not_to(change{ Card.count })
  #       end

  #       let(:model) { @card }
  #       include_examples 'creates an Activity', :update
  #     end

  #     describe 'submitting the form with invalid information' do
  #       before do
  #         visit edit_project_board_list_card_path(current_project, @board, @list, @card)
  #         fill_in :card_name, with: ''
  #       end

  #       it "doesn't update the card" do
  #         expect{submit_form}.not_to(change{ @card.reload.name })
  #       end

  #       it 'shows the form again with an error message' do
  #         submit_form
  #         expect(page).to have_text("can't be blank")
  #         expect(current_path).to eq(project_board_list_card_path(current_project, @board, @list, @card))
  #       end

  #       include_examples "doesn't create an Activity"
  #     end

  #     describe 'assigning users' do
  #       before do
  #         add_users
  #         @card.assignees = [@first_user]
  #         @card.save
  #         visit edit_project_board_list_card_path(current_project, @board, @list, @card)
  #       end

  #       it 'displays assigned checked and unassigned unchecked' do
  #         expect(page).to have_selector("input[type=checkbox][id=card_assignee_ids_#{@first_user.id}][checked=checked]")
  #         expect(page).to have_selector("input[type=checkbox][id=card_assignee_ids_#{@second_user.id}]:not(checked)")
  #       end

  #       it 'assigns selected and unassigns unselected' do
  #         uncheck @first_user.name
  #         check @second_user.name

  #         submit_form

  #         expect(page).not_to have_text(@first_user.name)
  #         expect(page).to have_text(@second_user.name)
  #       end
  #     end
  #   end

  #   describe 'when in show page' do
  #     before do
  #       @card = create(:card, list: @list)
  #       @card2 = create(:card, list: @list, previous_id: @card.id)
  #       @card3 = create(:card, list: @list, previous_id: @card2.id)
  #       create_activities
  #       create_comments
  #       visit project_board_list_card_path(current_project, @board, @list, @card)
  #     end

  #     let(:create_activities) { nil }
  #     let(:create_comments) { nil }

  #     let(:trackable) { @card }
  #     it_behaves_like 'a page with an activity feed'

  #     let(:commentable) { @card }
  #     it_behaves_like 'a page with a comments feed'

  #     let(:subscribable) { @card }
  #     it_behaves_like 'a page with subscribe/unsubscribe links'

  #     it 'has a link to edit card' do
  #       expect(page).to have_selector("a[href='#{edit_project_board_list_card_path(current_project, @board, @list, @card)}']")
  #     end

  #     it 'has a link to delete card' do
  #       expect(page).to have_selector("a[href='#{project_board_list_card_path(current_project, @board, @list, @card)}'][data-method='delete']")
  #     end

  #     describe "clicking 'delete'" do
  #       before { PaperTrail.enabled = true }
  #       after  { PaperTrail.enabled = false }

  #       let(:submit_form) { click_link 'Delete' }

  #       it 'deletes the card' do
  #         id = @card.id
  #         submit_form
  #         expect(Card.exists?(id)).to be false
  #         expect(current_path).to eq project_board_path(current_project, @board)
  #         expect(page).to have_text 'Task deleted'
  #       end

  #       it 'adjusts the list' do
  #         id = @card2.id
  #         submit_form
  #         expect(Card.find(id).previous_id).to be_nil
  #       end

  #       let(:model) { @card }
  #       let(:submit_form) { within('.note-text-inner') { click_link 'Delete' } }
  #       let(:trackable) { @card }

  #       include_examples 'creates an Activity', :destroy
  #     end
  #   end
  # end
end
