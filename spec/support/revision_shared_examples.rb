# A let variable called 'submit_form' should be defined, which performs the
# destroy action for the item, e.g.:
#
#     let(:submit_form) { click_link "delete" }
#
shared_examples "deleted item is listed in Trash" do |item_type|
  it "deletes the item and destroy revision is shown in Trash" do
    submit_form
    visit trash_path
    expect(page).to have_content item_type.to_s.capitalize
  end
end
