require 'rails_helper'

describe 'issue table' do

  describe 'toolbar', js: true do
    subject { page }

    let(:items) {
      issues = []
      (::Configuration.max_deleted_inline + 1).times do |i|
        issues << create(
          :issue,
          content: "#[Title]#\r\ntest#{i}\r\n\r\n#[Description]#\r\nnone#{i}\r\n",
          node: current_project.issue_library,
        )
      end
      issues
    }

    before do
      login_to_project_as_user
      Tag.create!(name: '!6baed6_low')
      @issues = items
      visit project_issues_path(current_project)
    end

    it_behaves_like 'an index table toolbar'

    context 'when clicking issues' do
      it 'displays merge button if more than 1 issues clicked' do
        check "checkbox_issue_#{@issues.first.id}"
        expect(page).to have_selector('#merge-selected', visible: false)
        check "checkbox_issue_#{@issues.last.id}"
        expect(page).to have_selector('#merge-selected', visible: true)
      end

      it 'resets toolbar after applying tags' do
        issue = @issues.first
        check "checkbox_issue_#{issue.id}"
        expect(page).to have_css('.js-items-table-actions')
        find('#tag-selected').click
        find('a[data-tag="!6baed6_low"]').click
        expect(page).to_not have_css('.js-items-table-actions')
        issue.reload
        expect(issue.tags.first.name).to eq '!6baed6_low'
      end
    end
  end
end
