require 'rails_helper'

describe 'Revisions#show:' do
  subject { page }

  describe 'when the record has 2 revisions' do

    let(:record) do
      with_versioning do
        create(:issue)
      end
    end

    before do
      login_to_project_as_user

      with_versioning do
        record.text = 'updated text'
        record.save
      end
    end
    
    it 'the 2 revisions are listed in the history table' do
      visit project_issue_revisions_path(current_project, record)

      within '.revisions-table tbody' do
        should have_selector('tr', count: 2)
        record.versions.each do |version| 
          should have_content("#{version.event}d".capitalize)
          should have_selector("time[datetime='#{version.created_at.strftime('%FT%TZ')}']")
          should have_content(version.whodunnit)
        end
      end
    end
  end
end
