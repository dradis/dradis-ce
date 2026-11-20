require 'rails_helper'

# Each import addon ships its own import box (issues/_import_box), so the
# addons test their own. The framework's results get the default row actions.
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

  before do
    login_to_project_as_user

    allow(Dradis::Plugins).to receive(:with_feature).and_call_original
    allow(Dradis::Plugins).to receive(:with_feature).with(:import).and_return([importer])
    Dradis::Plugins::Import::Filters.add(:testlibrary, :full_text_search, filter)
  end

  after do
    Dradis::Plugins::Import::Filters._filters.delete(:testlibrary)
  end

  describe 'POST /projects/:project_id/issues/import' do
    it 'lists the results with the default row actions' do
      post import_project_issues_path(current_project), params: { filter: 'full_text_search', query: 'SQL', scope: 'testlibrary' }

      row = Nokogiri::HTML(response.body).at_css('[data-behavior~=import-issues-results] tbody tr')
      expect(row.text).to include('SQL injection')
      expect(row.at_css('[data-behavior~=add-issue]')['data-state']).to eq('draft')
    end
  end
end
