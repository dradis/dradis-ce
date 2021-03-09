# This shared shared_example needs the folowing *let* variables:
# - board:
#   how to create a board (project level or node level)
# - board_path:
#   the path to board show page
shared_examples 'managing lists' do
  let(:model) { @list }

  let(:delete_link) do
    "a[href='#{project_board_list_path(current_project, @board, @list)}'][data-method='delete']"
  end
  
  before do
    @board = board
    @list  = create(:list, board: @board)
    @list2 = create(:list, board: @board, previous_id: @list.id)
    visit board_path
  end

  it 'contains a link to add a list' do
    expect(page).to have_text 'Add a list...'
  end

  it 'contains a link to rename each list' do
    List.all.each do |list|
      edit_link = "a[href='#modal-list-edit-#{list.id}']"
      expect(page).to have_selector(edit_link)
    end
  end

  it 'contains a link to add a card to the lists' do
    expect(page).to have_selector("a[href='#{new_project_board_list_card_path(current_project, @board,@list)}']")
  end

  describe 'adding a list' do
    let(:submit_form) { click_button 'Add list' }

    before do
      click_link 'Add a list...'
      expect(page).to have_selector('#modal-list-new', visible: true)
    end

    describe 'submitting the form with valid information' do
      before do
        within '#modal-list-new' do
          fill_in :new_list_name, with: 'New List'
        end
      end

      it 'creates a new list under this board' do
        expect do
          submit_form
          expect(page).to have_text('List added.')
          expect(page).to have_current_path(board_path)
        end.to change{List.count}.by(1)
      end

      include_examples 'creates an Activity', :create, List
    end

    describe 'submitting the form with invalid information' do
      before do
        within '#modal-list-new' do
          fill_in :new_list_name, with: ''
        end
      end

      it "doesn't create a new list" do
        old_count = List.count
        submit_form
        expect(page).to have_text("can't be blank")
        expect(old_count).to eq List.count
      end

      include_examples "doesn't create an Activity"
    end
  end

  describe 'updating a list', js: true do
    let(:submit_form) { click_button 'Update list' }

    let(:modal_selector) { "#modal-list-edit-#{@list.id}" }

    before do
      find("li[data-list-id='#{@list.id}']").hover
      find("a[href='#{modal_selector}']").click
      expect(page).to have_selector(modal_selector, visible: true)
    end

    describe 'submitting the form with valid information' do
      before do
        within modal_selector do
          fill_in "new_list_#{@list.id}_name", with: 'New List Name'
        end
      end

      it 'updates the list' do
        expect do
          submit_form
          expect(page).to have_text(/List renamed/i)
          expect(page).to have_text(/New List Name/i)
          expect(page).to have_current_path(board_path)
        end.not_to(change { List.count } )
      end

      include_examples 'creates an Activity', :update, @list
    end

    describe 'submitting the form with invalid information' do
      before do
        within modal_selector do
          fill_in "new_list_#{@list.id}_name", with: ''
        end
      end

      it "doesn't rename the list" do
        old_name = @list.name
        submit_form
        expect(page).to have_text("can't be blank")
        expect(old_name).to eq @list.reload.name
      end

      include_examples "doesn't create an Activity"
    end
  end

  it 'contains a link to delete each list' do
    expect(page).to have_selector(delete_link)
  end

  describe 'deleting a list' do
    let(:submit_form) { page.find(delete_link).click }
    it 'deletes the list' do
      id = @list.id
      submit_form
      expect(List.exists?(id)).to be false
      expect(page).to have_current_path(board_path)
      expect(page).to have_text 'List deleted'
    end

    it "updates the board's linked list" do
      id = @list2.id
      submit_form
      expect(List.find(id).previous_id).to be_nil
    end

    include_examples 'creates an Activity', :destroy
  end

  it 'displays assignees in each card' do
    # create card with 2 assigned users
    @card        = create(:card, list: @list)
    @first_user  = create(:user)
    @second_user = create(:user)
    @card.assignees << [@first_user, @second_user]
    @card.save

    # reload
    visit board_path

    expect(page).to have_selector("img[title='#{@first_user.name}']")
    expect(page).to have_selector("img[title='#{@second_user.name}']")
  end
end
