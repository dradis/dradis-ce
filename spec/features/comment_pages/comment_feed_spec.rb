require 'rails_helper'

describe 'Comment feed', js: true do
  before { login_to_project_as_user }

  include CommentMacros

  let!(:issue) { create(:issue, node: current_project.issue_library) }

  let!(:comments) do
    [
      create(:comment, commentable: issue, user: @logged_in_as),
      create(:comment, commentable: issue)
    ]
  end

  let!(:evidence_comment) { create(:comment, commentable: create(:evidence)) }

  before do
    visit project_issue_path(current_project, issue)

    # Wait for ajax
    find('[data-behavior~=fetch-comments] .comment-feed')
  end

  describe 'list comments' do
    it 'shows up in the list' do
      within comment_feed do
        expect(page).to have_comment(comments[0])
        expect(page).to have_comment(comments[1])
        expect(page).to_not have_comment(evidence_comment)
      end

      within "div##{dom_id(comments[0])}" do
        expect(page).to have_selector('span.user', text: @logged_in_as.name)
      end
    end
  end

  describe 'add comment' do
    let(:submit_form) do
      within 'form[data-behavior~=add-comment]' do
        fill_in 'comment[content]', with: 'test comment'
        click_button 'Add comment'
      end

      expect(page).to have_text 'test comment' # forces waiting for ajax
    end

    it 'allows adding a comment' do
      submit_form

      within comment_feed do
        expect(Comment.last.content).to eq 'test comment'
      end
    end

    include_examples 'creates an Activity', :create, Comment

    describe 'local caching' do
      it 'prefills textarea with cached value and clears it when saved' do
        within 'form[data-behavior~=local-auto-save]' do
          fill_in 'comment[content]', with: 'test comment'
          sleep 1 # Needed for debounce function in local_auto_save.js
        end

        page.refresh

        content = page.find_field('comment[content]').value
        expect(content).to eq 'test comment'

        within 'form[data-behavior~=local-auto-save]' do
          click_button 'Add comment'
        end

        page.refresh

        content = page.find_field('comment[content]').value
        expect(content).to eq ''
      end
    end
  end

  describe 'update comment' do
    let(:model) { comments[0] }

    let(:submit_form) do
      find("div#comment_#{model.id}").hover

      within "div#comment_#{model.id}" do
        click_link 'Edit'
        expect(page).to have_css('textarea')
        fill_in 'comment[content]', with: 'test comment edited'
        click_button 'Update comment'
      end

      expect(page).to have_text 'test comment edited' # forces waiting for ajax
    end

    context 'own comments' do
      it 'can be updated' do
        submit_form

        within comment_feed do
          expect(model.reload.content).to eq 'test comment edited'
        end
      end
    end

    include_examples 'creates an Activity', :update

    context 'other user comments' do
      it 'does not show edit link' do
        id = comments[1].id

        within "div#comment_#{id}" do
          expect(page).to have_link('Edit', visible: false)
          expect(page).not_to have_css "form#edit_comment_#{id}"
        end
      end
    end

    describe 'local caching' do
      before do
        find("div#comment_#{model.id}").hover

        within "div#comment_#{model.id}" do
          click_link 'Edit'
          fill_in 'comment[content]', with: 'test comment edited'
          sleep 1 # Needed for debounce function in local_auto_save.js
        end

        page.refresh
      end

      it 'prefills textarea with cached value and clears cached value when cancel is clicked' do
        find("div#comment_#{model.id}").hover

        within "div#comment_#{model.id}" do
          click_link 'Edit'
          content = page.find_field('comment[content]').value
          expect(content).to eq 'test comment edited'
        end

        expect(model.reload.content).not_to eq 'test comment edited'

        within "div#comment_#{model.id}" do
          click_link 'Cancel'
        end

        page.refresh

        find("div#comment_#{model.id}").hover

        within "div#comment_#{model.id}" do
          click_link 'Edit'
          content = page.find_field('comment[content]').value
          expect(content).not_to eq 'test comment edited'
        end
      end
    end
  end

  describe 'delete comment' do
    let(:model) { comments[0] }

    let(:submit_form) do
      find("div#comment_#{model.id}").hover

      within "div#comment_#{model.id}" do
        accept_confirm { click_link 'Delete' }
      end

      expect(page).not_to have_comment(model) # forces waiting for ajax
    end

    it 'allows deleting a comment from the same user' do
      submit_form

      within comment_feed do
        expect(page).not_to have_text(model.content)
        expect(Comment.find_by_id(model.id)).to be_nil
      end

      other_user_comment_id = comments[1].id
      within "div#comment_#{other_user_comment_id}" do
        expect(page).to have_link('Delete', visible: false)
      end
    end

    include_examples 'creates an Activity', :destroy
  end
end
