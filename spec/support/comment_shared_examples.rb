# Define the following let variables before using these examples:
#
#   create_comments : a block which creates the activities AND IS CALLED
#                     BEFORE THE PAGE LOADS
#   commentable: the model which the 'show' page is about
shared_examples 'a page with a comments feed' do

  describe 'when the model has comments' do
    include CommentMacros

    let(:create_comments) do
      @comments = [
        create(:comment, commentable: commentable),
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
  end
end
