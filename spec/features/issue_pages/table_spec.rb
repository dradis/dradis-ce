require 'rails_helper'

describe 'issue pages' do
  describe '#index table', js: true do
    subject { page }

    before do
      login_to_project_as_user

      @issue = create(
        :issue,
        text: "#[Title]#\nIssue1\n\n#[Risk]#\nHigh\n\n#[Description]#\nn/a",
        node: current_project.issue_library
      )

      create(:issue, node: current_project.issue_library)

      @tags = Tag::DEFAULT_TAGS.map do |tag|
        if defined?(Dradis::Pro)
          create(:tag, name: tag, project: current_project)
        else
          create(:tag, name: tag)
        end
      end

      visit project_issues_path(current_project)
    end

    let(:default_columns) { ['Title', 'Tags'] }
    let(:hidden_columns) { ['Description', 'Risk'] }
    let(:filter) { { keyword: @issue.title, filter_count: 1 } }

    it_behaves_like 'a DataTable'

    let(:new_content) { "#[Title]#\nNew Title\n\n#[Risk]#\nHigh\n\n#[Description]#\nn/a\n\n#[New Field]#\nNew Field Value" }
    let(:old_content) { "#[Title]#\nIssue1\n\n#[Risk]#\nHigh\n\n#[Description]#\nn/a" }
    let(:resource) { @issue }
    let(:content_attribute) { :text }

    it_behaves_like 'a DataTable with Dynamic Columns'

    describe 'bulk delete that runs in the background' do
      before do
        Configuration.create!(name: 'admin:max_deleted_inline', value: 0)
        login_as(@logged_in_as) # the console's ActionCable connection needs a real Warden session
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true # the suite's :test adapter won't run perform_later jobs otherwise
      end

      after { ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false }

      it 'streams the job log into the console modal and redirects once closed' do
        within '.dataTables_wrapper' do
          page.find('td.select-checkbox', match: :first).click

          page.accept_confirm do
            click_button('Delete')
          end
        end

        # Individual log lines aren't asserted here: broadcasts sent before
        # the browser's subscription is established are lost, same as the
        # upload console's console-mount stream, so intermediate lines
        # aren't guaranteed. The final status always reflects reality
        # (see Log.latest_for), which is what the redirect depends on.
        within '#modal-console' do
          expect(page).to have_text('Complete.', wait: 10)

          click_button 'Done!'
        end

        expect(page).to have_current_path(project_issues_path(current_project), wait: 10)
      end
    end
  end
end
