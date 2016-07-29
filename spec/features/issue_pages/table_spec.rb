require "spec_helper"

describe "issue pages" do


  describe "#index table", js2: true do
    subject { page }

    before do
      login_to_project_as_user

      @issue = create(:issue, text: "#[Risk]#\nHigh\n\n#[Description]#\nn/a")
      visit issues_path
    end

    it "displays column controls for Title, Tags and Affected" do

      # Prime the element's text, as it is hidden by default
      find('.js-table-columns', visible: false).text(:all)

      expect(find('.js-table-columns', visible: false)).to have_text('Title')
      expect(find('.js-table-columns', visible: false)).to have_text('Tags')
      expect(find('.js-table-columns', visible: false)).to have_text('Affected')
    end

    it "displays custom columns based on Issue content" do
      # Prime the element's text, as it is hidden by default
      find('.js-table-columns', visible: false).text(:all)

      expect(@issue.fields.keys).to include('Risk', 'Description')
      @issue.fields.keys.each do |column|
        expect(find('.js-table-columns', visible: false)).to have_text(column)
      end
    end

    it "displays combine button when more than one issue selected" do

    end

    it "builds a form with selected issues when combine button clicked" do

    end

  end
end