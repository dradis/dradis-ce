require 'rails_helper'

describe 'issue pages' do
  describe 'merge page', js: true do
    before do
      login_to_project_as_user

      # create 2 issues
      @issue1 = create(:issue, node: current_project.issue_library)
      @issue2 = create(:issue, node: current_project.issue_library)
    end

    describe 'textile form view' do
      let(:action_path) { new_project_merge_path(current_project, ids: [@issue1.id, @issue2.id]) }
      it_behaves_like 'a .textile form'
    end

    context 'merge actions' do
      before do
        visit new_project_merge_path(current_project, ids: [@issue1.id, @issue2.id])
        expect(page).to have_content /You're merging 2 Issues into a target Issue/i
      end

      # After the merge form submits, the redirect lands on Issues#show
      # which fires an async fetch (liquid_async). Wait for it to
      # complete (spinner hidden) so it doesn't become a ghost request
      # after the transactional fixture rolls back.
      def submit_and_wait
        click_button 'Merge issues'
        expect(page).to have_css('[data-behavior~="liquid-spinner"].d-none', visible: :all)
      end

      it 'merges issues into an existing one' do
        submit_and_wait

        expect(page).to have_content('1 issue merged into ')
      end

      it 'creates a new issue' do
        choose('Merge into a new issue')
        expect(page).to have_css('#preview_issue_new.show')
        click_link 'Source'

        submit_and_wait

        expect(page).to have_content(/2 issues merged into/i)

        # We start with 2, but merge into a single one
        expect(Issue.count).to eq(1)
        expect(Issue.last.author).to eq(@logged_in_as.email)
      end

      it 'tags the new issue based on the #[Tags]#' do
        choose('Merge into a new issue')
        expect(page).to have_css('#preview_issue_new.show')

        tag_name = '!2ca02c_info'
        click_link 'Source'
        fill_in :issue_text, with: "#[Title]#\nMerged issue\n\n#[Tags]#\n#{tag_name}\n\n"

        submit_and_wait

        expect(page).to have_content(/2 issues merged into Merged issue/i)
        expect(Issue.last.reload.tag_list).to eq(tag_name)
      end

      let(:submit_form) {
        submit_and_wait
      }
      include_examples 'deleted item is listed in Trash', :issue
    end
  end
end
