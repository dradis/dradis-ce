require 'rails_helper'

describe "issue trash" do
  subject { page }

  before do
    login_to_project_as_user
  end

  example "reflects edit of a previously deleted issue" do
    @issue = create(:issue)
    edit_and_delete_issue "issue 1"

    visit project_trash_path(current_project)
    click_link 'Recover'

    @issue = Note.find(@issue.id)
    edit_and_delete_issue "issue 2"

    visit project_trash_path(current_project)
    expect(find(".item-content").text).to eq(@issue.title)
  end


  def edit_and_delete_issue title
    @issue.update_attribute(
      :text,
      "#[Title]#\r\n#{title}\r\n\r\n#[Description]#\r\n\r\n"
    )
    @issue.destroy
    @issue.versions.last.update_attribute(:project_id, current_project.id)
  end
end
