# This shared example needs the folowing *let* variables:
# commentable: the model which the 'show' page is about

shared_examples 'a page with comment feed' do
  let(:params) do
    {
      comment: {
        commentable_type: commentable.class,
        commentable_id: commentable.id
      }
    }
  end

  it 'contains the fetch-comments element' do
    expect(page).to have_selector("[data-behavior='fetch fetch-comments'][data-path='#{comments_path(params)}']")
  end
end
