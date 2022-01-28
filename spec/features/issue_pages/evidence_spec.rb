require 'rails_helper'

describe 'issue pages evidence tab' do
  describe '#index table', js: true do
    subject { page }
    let(:issue) { create(:issue, node: current_project.issue_library) }
    let(:node) { create(:node, project: current_project) }

    before do
      login_to_project_as_user

      3.times do
        create(:evidence, issue: issue, node: node)
      end

      @tags = Tag::DEFAULT_TAGS.map do |tag|
        if defined?(Dradis::Pro)
          create(:tag, name: tag, project: current_project)
        else
          create(:tag, name: tag)
        end
      end

      visit project_issue_path(current_project, issue)
      click_link("Evidence #{issue.evidence.count}")
    end

    let(:default_columns) { ['Node', 'Created by'] }
    let(:hidden_columns) { ['Updated'] }
    let(:filter) { { keyword: issue.evidence.first.title, filter_count: 1 } }

    it_behaves_like 'a DataTable'
  end
end
