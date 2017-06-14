require 'rails_helper'

describe "note pages", js: true do
  include ActivityMacros

  subject { page }

  before do
    login_as_user
    @other_user = create(:user, :admin)
    @node       = create(:node)
    @note       = create(:note, node: @node)
  end

  shared_examples "a note page with poller" do
    describe "and someone else updates the same Note" do
      before do
        @note.update_attributes(text: "whatever")
        track_updated(@note, @other_user)

        call_poller
      end

      it "displays a warning" do
        should have_selector "#note-updated-alert"
      end
    end

    describe "and someone deletes that Note" do
      before do
        @note.destroy
        track_destroyed(@note, @other_user)
        call_poller
      end

      it "displays a warning" do
        should have_selector "#note-deleted-alert"
      end
    end

    describe "and someone updates then deletes that note" do
      before do
        @note.update_attributes(text: "whatever")
        track_updated(@note, @other_user)
        @note.destroy
        track_destroyed(@note, @other_user)
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
    before { visit node_note_path(@node, @note) }
    it_behaves_like "a note page with poller"
  end

  describe "when I am editing a Note" do
    before { visit edit_node_note_path(@node, @note) }
    it_behaves_like "a note page with poller"
  end
end
