require "spec_helper"

describe "issue table" do

  describe "toolbar", js: true do
    subject { page }

    before do
      login_to_project_as_user

      create(:issue, text: "#[Title]#\r\ntest1\r\n\r\n#[Description]#\r\nnone1\r\n")
      create(:issue, text: "#[Title]#\r\ntest2\r\n\r\n#[Description]#\r\nnone2\r\n")

      visit issues_path
    end

    it "selects all issues" do
      find('.js-select-all-issues').click

      all('input[type=checkbox].js-multicheck').each do |el|
        expect(el['checked']).to be true
      end
    end
  end
end
