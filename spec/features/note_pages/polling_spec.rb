require 'rails_helper'

describe "note pages", js: true do
  include ActivityMacros

  subject { page }

  before do
    login_to_project_as_user
    @other_user = create(:user, :admin)
    @node       = create(:node, project: current_project)
    @note       = create(:note, node: @node)
  end

  shared_examples "a note page with poller" do
    describe "and someone else updates the same Note" do
      before do
        @note.update(text: "whatever")
        create(:activity, action: :update, trackable: @note, user: @other_user)


        call_poller
      end

      it "displays a warning" do
        should have_selector "#note-updated-alert"
      end
    end

    describe "and someone deletes that Note" do
      before do
        @note.destroy
        create(:activity, action: :destroy, trackable: @note, user: @other_user)

        call_poller
      end

      it "displays a warning" do
        should have_selector "#note-deleted-alert"
      end
    end

    describe "and someone updates then deletes that note" do
      before do
        @note.update(text: "whatever")
        create(:activity, action: :update, trackable: @note, user: @other_user)
        @note.destroy
        create(:activity, action: :destroy, trackable: @note, user: @other_user)
        call_poller
      end

      it "displays a warning" do
        # Make sure the 'update' actions pointing to a no-longer-existent Note
        # don't crash the poller!
        should have_selector "#note-deleted-alert"
      end
    end
  end

  describe "when I am viewing a Note" do
    before { visit project_node_note_path(current_project, @node, @note) }
    it_behaves_like "a note page with poller"
  end

  describe "when I am editing a Note" do
    before { visit edit_project_node_note_path(current_project, @node, @note) }
    it_behaves_like "a note page with poller"
  end
end
