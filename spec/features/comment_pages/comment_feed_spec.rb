require 'rails_helper'

describe 'Comment feed', js: true do
  before { login_to_project_as_user }

  include CommentMacros

  let!(:issue) { create(:issue) }
  let!(:comments) do
    [
      create(:comment, commentable: issue, user: @logged_in_as),
      create(:comment, commentable: issue)
    ]
  end

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
      end
    end

    it 'display user\'s name in comment row' do
      within "div##{dom_id(comments[0])}" do
        expect(page).to have_selector('span.user', text: @logged_in_as.name)
      end
    end

    context 'other commentable comments' do
      let!(:evidence_comment) { create(:comment, commentable: create(:evidence)) }

      it 'does not show up in the list' do
        within comment_feed do
          expect(page).to_not have_comment(evidence_comment)
        end
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
      context 'when comment is not saved' do
        it 'prefills textarea with cached value' do
          within 'form[data-behavior~=local-auto-save]' do
            fill_in 'comment[content]', with: 'test comment'
            sleep 1 # Needed for debounce function in local_auto_save.js
          end

          page.refresh

          content = page.find_field('comment[content]').value
          expect(content).to eq 'test comment'
        end
      end

      context 'when comment is saved' do
        it 'clears cached value' do
          within 'form[data-behavior~=local-auto-save]' do
            fill_in 'comment[content]', with: 'test comment'
            sleep 1 # Needed for debounce function in local_auto_save.js
            click_button 'Add comment'
          end

          page.refresh

          content = page.find_field('comment[content]').value
          expect(content).to eq ''
        end
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
      end

      context 'when comment is not updated' do
        it 'prefills textarea with cached value' do
          page.refresh

          find("div#comment_#{model.id}").hover

          within "div#comment_#{model.id}" do
            click_link 'Edit'
            content = page.find_field('comment[content]').value
            expect(content).to eq 'test comment edited'
          end
        end

        it 'does not save unsaved changes in database' do
          expect(model.reload.content).not_to eq 'test comment edited'
        end
      end

      context 'when cancel is clicked' do
        it 'clears cached value' do
          page.refresh

          find("div#comment_#{model.id}").hover

          within "div#comment_#{model.id}" do
            click_link 'Edit'
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
    end

    include_examples 'creates an Activity', :destroy

    it 'does not allow deleting a comment from another user' do
      id = comments[1].id

      within "div#comment_#{id}" do
        expect(page).to have_link('Delete', visible: false)
      end
    end
  end
end
