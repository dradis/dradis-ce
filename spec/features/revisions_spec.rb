require 'rails_helper'

describe 'Revisions#show:' do
  subject { page }

  describe 'when the record has activities' do

    let(:record) do
      with_versioning do
        create(:issue)
      end
    end

    before do
      login_to_project_as_user
      record.text = 'updated text'
      record.save
    end
    
    it 'lists them in the activity feed' do
      visit project_issue_revisions_path(current_project, record)

      within '.revisions-table tbody' do
        should have_selector('tr', count: record.versions.count)
        record.versions.each do |version| 
          should have_content("#{version.event}d".capitalize)
          should have_selector("time[datetime='#{version.created_at.strftime('%FT%TZ')}']")
          should have_content(version.whodunnit)
        end
      end
    end
  end
end
