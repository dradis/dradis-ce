require 'rails_helper'

describe "issue trash" do

  subject { page }

  before do
    login_as_user
  end

  example "reflects edit of a previously deleted issue" do
    @issue = create(:issue)
    edit_and_delete_issue "issue 1"

    visit "/trash"
    click_link 'Recover'

    @issue = Note.find(@issue.id)
    edit_and_delete_issue "issue 2"

    visit "/trash"
    expect(find(".item-content").text).to eq(@issue.title)
  end


  def edit_and_delete_issue title
    @issue.update_attribute(
      :text,
      "#[Title]#\r\n#{title}\r\n\r\n#[Description]#\r\n\r\n"
    )
    @issue.destroy
  end

end
