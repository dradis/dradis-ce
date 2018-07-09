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
      expect(page).to have_comment(@comments[0])
      expect(page).to have_comment(@comments[1])
      expect(page).not_to have_comment(@other_comment)
    end
  end

  it 'allows adding a comment' do
    within 'form#new_comment' do
      fill_in 'comment_content', with: 'test comment'
      click_button 'Add comment'
    end

    expect(page).to have_text 'test comment'
  end

  it 'allows updating a comment from the same user' do
    id = @comments[0].id
    within "div#comment_#{id}" do
      fill_in 'comment_content', with: 'test comment edited'
      click_button 'Update comment'
    end

    expect(page).to have_text 'test comment edited'
  end

  it 'does not allow to edit comments from other users' do
    id = @comments[1].id
    within "div#comment_#{id}" do
      expect(page).not_to have_link 'Edit'
      expect(page).not_to have_css "form#edit_comment_#{id}"
    end
  end

  it 'allows deleting a comment from the same user' do
    id = @comments[0].id
    within "div#comment_#{id}" do
      click_link 'Delete'
    end

    expect(page).not_to have_comment(@comments[0])
  end

  it 'does not allow deleting a comment from another user' do
    id = @comments[1].id
    within "div#comment_#{id}" do
      expect(page).not_to have_link('Delete')
    end
  end
end
