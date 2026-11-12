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

    describe 'column filters' do
      let(:risk_filter) { "[data-behavior~=column-filter][aria-label='Filter Risk']" }
      let(:title_filter) { "[data-behavior~=column-filter][aria-label='Filter Title']" }

      it 'filters a column hidden on load' do
        find('.buttons-colvis').click
        within('.dt-button-collection') { click_link 'Risk' }
        find('body').send_keys(:escape)
        click_button 'Filters'
        find(risk_filter).set('High')
        expect(page).to have_css('.dataTable tbody tr', count: 1)
        expect(page).to have_css('.dataTable tbody tr', text: @issue.title)
      end

      it 'restores the filters on reload and clears them when closed' do
        click_button 'Filters'
        find(title_filter).set(@issue.title)

        visit project_issues_path(current_project)
        expect(page).to have_button('Filters: On')
        expect(find(title_filter).value).to eq(@issue.title)
        expect(page).to have_css('.dataTable tbody tr', count: 1)
        expect(page).to have_css('.dataTable tbody tr', text: @issue.title)

        click_button 'Filters'
        expect(page).to have_button('Filters: Off')
        expect(page).to_not have_css(title_filter)
        expect(page).to have_css('.dataTable tbody tr', count: 2)
      end
    end
  end
end
