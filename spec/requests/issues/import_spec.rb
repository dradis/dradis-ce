require 'rails_helper'

# Each import addon ships its own search UI as issues/_import_box under its
# engine's view path. An addon that only registers Import::Filters renders the
# default search form, and its results get the default row actions.
describe 'Issues import' do
  let(:importer) do
    double('import addon', name: 'Dradis::Plugins::Testlibrary::Engine', plugin_description: 'Test library', plugin_name: :testlibrary)
  end
  let(:filter) do
    Class.new(Dradis::Plugins::Import::Filters::Base) do
      def query(_params = {})
        [Dradis::Plugins::Import::Result.new(description: "#[Title]#\nSQL injection\n", title: 'SQL injection')]
      end
    end
  end
  let!(:view_paths) { ApplicationController.view_paths }

  before do
    login_to_project_as_user

    allow(Dradis::Plugins).to receive(:with_feature).and_call_original
    allow(Dradis::Plugins).to receive(:with_feature).with(:import).and_return([importer])
    Dradis::Plugins::Import::Filters.add(:testlibrary, :full_text_search, filter)
    ApplicationController.prepend_view_path(Rails.root.join('spec/fixtures/views'))
  end

  after do
    Dradis::Plugins::Import::Filters._filters.delete(:testlibrary)
    ApplicationController.view_paths = view_paths
  end

  describe 'the import box' do
    it 'renders the import addon\'s own issues/_import_box' do
      get project_issues_path(current_project)

      box = Nokogiri::HTML(response.body).at_css('#testlibrary_import')
      expect(box.text).to include('Test library')
      expect(box.at_css('form')['action']).to eq(import_project_issues_path(current_project))
      expect(box.at_css('input[name=scope]')['value']).to eq('testlibrary')
      expect(box.at_css('input[name=filter]')['value']).to eq('full_text_search')
    end
  end

  describe 'POST /projects/:project_id/issues/import' do
    it 'lists the results with the default row actions and keeps the query in the search box' do
      post import_project_issues_path(current_project), params: { filter: 'full_text_search', query: 'SQL', scope: 'testlibrary' }

      page = Nokogiri::HTML(response.body)
      row = page.at_css('[data-behavior~=import-issues-results] tbody tr')
      expect(row.text).to include('SQL injection')
      expect(row.at_css('[data-behavior~=add-issue]')['data-state']).to eq('draft')
      expect(page.at_css('#testlibrary_import input[name=query]')['value']).to eq('SQL')
    end
  end
end
