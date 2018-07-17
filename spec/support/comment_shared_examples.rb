# Define the following let variables before using these examples:
#
#   create_comments : a block which creates the activities AND IS CALLED
#                     BEFORE THE PAGE LOADS
#   commentable: the model which the 'show' page is about
shared_examples 'a page with a comments feed' do

  include CommentMacros

  let(:create_comments) do
    @comments = [
      create(:comment, commentable: commentable, user: @logged_in_as),
      create(:comment, commentable: commentable)
    ]
    other_instance = create(commentable.class.to_s.underscore)
    @other_comment = create(:comment, commentable: other_instance)
  end

  it 'lists them in the content feed' do
    within comment_feed do
      should have_comment(@comments[0])
      should have_comment(@comments[1])
      should_not have_comment(@other_comment)
    end
  end

  describe 'add comment' do
    let(:submit_form) do
      within 'form#new_comment' do
        fill_in 'comment_content', with: 'test comment'
        click_button 'Add comment'
      end
    end

    it 'allows adding a comment' do
      submit_form

      expect(page).to have_text 'test comment'
    end

    include_examples 'creates an Activity', :create, Comment
  end

  describe 'update comment' do
    let(:model) { @comments[0] }
    let(:submit_form) do
      within "div#comment_#{model.id}" do
        fill_in 'comment_content', with: 'test comment edited'
        click_button 'Update comment'
      end
    end

    it 'allows updating a comment from the same user' do
      submit_form

      expect(page).to have_text 'test comment edited'
    end

    include_examples 'creates an Activity', :update

    it 'does not allow to edit comments from other users' do
      id = @comments[1].id
      within "div#comment_#{id}" do
        expect(page).not_to have_link 'Edit'
        expect(page).not_to have_css "form#edit_comment_#{id}"
      end
    end
  end

  describe 'delete comment' do
    let(:model) { @comments[0] }
    let (:submit_form) do
      within "div#comment_#{model.id}" do
        click_link 'Delete'
      end
    end

    it 'allows deleting a comment from the same user' do
      submit_form

      expect(page).not_to have_comment(@comments[0])
    end

    include_examples 'creates an Activity', :destroy

    it 'does not allow deleting a comment from another user' do
      id = @comments[1].id
      within "div#comment_#{id}" do
        expect(page).not_to have_link('Delete')
      end
    end
  end
end
