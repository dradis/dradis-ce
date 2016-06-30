# A let variable called 'submit_form' should be defined, which performs the
# destroy action for the item, e.g.:
#
#     let(:submit_form) { click_link "delete" }
#
shared_examples "deleted item is listed in Trash" do |item_type|
  it "deletes the item and destroy revision is shown in Trash" do
    submit_form
    visit trash_path
    within '#trash' do
      expect(page).to have_content item_type.to_s
    end
  end
end

# Apart from the 'submit_form' let variable described above, another let variable
# called 'model' should be defined, which will be the object to recover.
shared_examples "recover deleted item" do |item_type|
  it "should recover item listed in Trash", js: true do
    submit_form
    visit trash_path
    page.accept_confirm do
      click_link 'Recover'
    end
    expect(page).to have_content "Item recovered"
    within '#trash' do
      expect(page).not_to have_content item_type.to_s
    end
    expect(model.class.find_by_id(model.id)).not_to be_nil
  end
end
