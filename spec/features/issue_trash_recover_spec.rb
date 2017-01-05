require "spec_helper"

describe "issue trash" do

  subject { page }

  before do
    login_to_project_as_user
  end

  example "reflects edit of a previously deleted issue" do
    @issue = create(:issue)
    edit_and_delete_issue "issue 1"

    # this test saves multiple versions of the issue. If the DB doesn't store
    # datetimes with enough precision, and the spec runs fast enough, it might
    # not be able to tell which issue was created first, meaning the spec will
    # fail randomly (as it was previously doing on CI).  Manually overriding
    # the created_at timestamp prevents this.
    @issue.versions.last.update!(created_at: 5.seconds.ago)

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
