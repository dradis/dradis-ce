# A let variable called 'submit_form' should be defined, which performs the
# destroy action for the item, e.g.:
#
#     let(:submit_form) { click_link "delete" }
#
shared_examples "deleted item is listed in Trash" do |item_type|
  it "deletes the item and destroy revision is shown in Trash" do
    with_versioning do
      submit_form
      visit project_trash_path(current_project)
      within '#trash' do
        expect(page).to have_content item_type.to_s
      end
    end
  end
end

# Apart from the 'submit_form' let variable described above, another let variable
# called 'model' should be defined, which will be the object to recover.
shared_examples "recover deleted item" do |item_type|
  it "should recover item listed in Trash", js: true do
    with_versioning do
      submit_form
      visit project_trash_path(current_project)
      activity_count = model.try(:activities) ? model.activities.count : 0

      expect do
        page.accept_confirm do
          rr_path = recover_project_revision_path(current_project, model.versions.last)
          find(:xpath, "//a[@href='#{rr_path}']").click
        end
        expect(page).to have_content "#{model.class.name.humanize} recovered"
      end.to have_enqueued_job(ActivityTrackingJob).with(
        action: 'recover',
        project_id: current_project.id,
        trackable_id: model.id,
        trackable_type: model.class.to_s,
        user_id: @logged_in_as.id
      )

      within '#trash' do
        expect(page).not_to have_content item_type.to_s
      end
      expect(model.class.find_by_id(model.id)).not_to be_nil
    end
  end
end

# Apart from the 'submit_form' let variable described above, another let variable
# called 'model' should be defined, which will be the object to recover.
shared_examples "recover deleted item without node" do |item_type|
  it "should recover item listed in Trash even if its node has been destroyed", js: true do
    with_versioning do
      submit_form
      visit project_node_path(model.node.project, model.node.id)
      click_link 'Delete'
      within '#modal_delete_node' do
        click_link 'Delete'
      end

      expect do
        visit project_trash_path(current_project)
        rr_path = recover_project_revision_path(current_project, model.versions.last)
        page.accept_confirm do
          find(:xpath, "//a[@href='#{rr_path}']").click
        end
      end.to have_enqueued_job(ActivityTrackingJob).with(
        action: 'recover',
        project_id: current_project.id,
        trackable_id: model.id,
        trackable_type: model.class.to_s,
        user_id: @logged_in_as.id
      )

      expect(page).to have_content "#{model.class.name.humanize} recovered"
      within '#trash' do
        expect(page).not_to have_content item_type.to_s
      end
      expect(model.class.find_by_id(model.id)).not_to be_nil
      expect(page).to have_content 'Recovered'
    end
  end
end
