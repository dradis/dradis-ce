require 'rails_helper'

describe 'Revisions#show:' do
  subject { page }

  describe 'when the record has 2 revisions' do
    let(:record) do
      with_versioning do
        create(:issue, node: current_project.issue_library)
      end
    end

    before do
      login_to_project_as_user

      with_versioning do
        record.text = 'updated text'
        record.save
      end
    end

    it 'lists the revisions in the history table' do
      visit project_issue_revisions_path(current_project, record)

      within '.revisions-table tbody' do
        should have_selector('tr', count: 2)
        record.versions.each do |version|
          should have_content("#{version.event}d".capitalize)
          should have_selector("time[datetime='#{version.created_at.strftime('%FT%TZ')}']")
        end
      end
    end
  end
end
