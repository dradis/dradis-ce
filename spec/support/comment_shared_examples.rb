# Define the following let variables before using these examples:
#
#   create_comments : a let block which creates the comments AND IS CALLED
#     BEFORE THE PAGE LOADS. These specs assume that create_comments is a no-op
#     by default
#   commentable: the model which the 'show' page is about, e.g.
#     if we're viewing /projects/x/issues/1, commentable = issue with ID 1
#
# NB 'visit whatever_path' should be called BEFORE these tests are run
shared_examples 'a page with a comments feed' do
  include CommentMacros

  # We can't add js: true to the shared_example block itself, so we have to add
  # this extra layer of nesting. (This is better in my opinion than having to
  # remember to activate js 'one level up' in every file that calls this shared
  # example group.
  context '', js: true do
    let(:no_comments_text) { 'There have been no comments yet.' }

    example '"there are no comments" text' do
      expect(page).to have_content no_comments_text
      submit_new_comment(content: 'test comment')
      expect(page).to have_no_content no_comments_text
      click_delete_comment_link(Comment.last)
      expect(page).to have_content no_comments_text
    end

    example 'comments count number' do
      def have_comments_count(number)
        have_css '#comments-count-badge', text: number.to_s
      end

      expect(page).to have_comments_count(0)
      submit_new_comment(content: 'test comment 1')
      expect(page).to have_comments_count(1)
      submit_new_comment(content: 'test comment 2')
      expect(page).to have_comments_count(2)
      click_delete_comment_link(Comment.last)
      expect(page).to have_comments_count(1)
      click_delete_comment_link(Comment.last)
      expect(page).to have_comments_count(0)
    end

    context 'when there are already comments' do
      let(:create_comments) do
        @comments = [
          create(:comment, commentable: commentable, user: @logged_in_as),
          create(:comment, commentable: commentable)
        ]
        other_commentable = create(commentable.class.to_s.underscore)
        @other_comment    = create(:comment, commentable: other_commentable)
      end

      let(:my_comment) { @comments[0] }
      let(:not_my_comment) { @comments[1] }

      it 'lists them in the content feed' do
        within comment_feed do
          expect(page).to have_comment(@comments[0])
          expect(page).to have_comment(@comments[1])
          expect(page).to have_no_comment(@other_comment)
        end
      end

      example 'adding a comment' do
        submit_new_comment(content: 'test comment')
        expect(page).to have_text 'test comment'

        comment = Comment.find_by!(content: 'test comment')
        within_comment(comment) do
          expect(page).to have_content @logged_in_as.email
          # I can edit and delete my own new comments
          expect(page).to have_link 'Edit', visible: false
          expect(page).to have_link 'Delete', visible: false
        end

        # form is cleared and button is re-enabled
        # (Don't forget there will be (hidden) forms on to page to edit
        # comments, and they'll also have a field #comment_content)
        textarea = find('.new_comment #comment_content')
        expect(textarea.value).to eq ''
        submit_btn = find("#comment_form_submit_btn")
        expect(submit_btn[:disabled]).to be_falsey
        expect(submit_btn.value).to eq 'Add comment'
      end

      example 'updating my own comment' do
        click_edit_comment_link(my_comment)
        within_comment(my_comment) do
          fill_in :comment_content, with: 'test comment edited'
          click_button 'Update comment'
          expect(page).to have_text 'test comment edited'
        end

        # Bug fix: after updating once, the 'edit' button still works and you
        # can update the same comment again.
        click_edit_comment_link(my_comment)
        within_comment(my_comment) do
          fill_in :comment_content, with: 'test comment edited again'
          click_button 'Update comment'
          expect(page).to have_text 'test comment edited again'
        end
      end

      it 'does not allow to edit comments from other users' do
        within_comment(not_my_comment) do
          expect(page).to have_no_link 'Edit'
          expect(page).to have_no_css "form#edit_comment_#{not_my_comment.id}"
        end
        # TODO test they can't edit by direct HTTP request
      end

      it 'allows deleting a comment from the same user' do
        click_delete_comment_link(my_comment)
        expect(page).to have_no_comment my_comment
      end

      it 'does not allow deleting a comment from another user' do
        within_comment(not_my_comment) do
          expect(page).to have_no_link('Delete')
        end
        # TODO test they can't delete by direct HTTP request
      end

      # TODO test that other user's edits/updates/destroys appear with
      # websockets. Probably a bunch of obvious bugs to test - e.g. make sure
      # that new comments only appear if they're for the current page!
    end
  end
end
