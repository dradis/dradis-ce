require 'rails_helper'

describe "evidence pages", js: true do
  include ActivityMacros

  subject { page }

  shared_examples "an evidence page with poller" do
    describe "when someone else updates the current Evidence" do
      before do
        @evidence.update_attributes(content: "whatever")
        track_updated(@evidence, @other_user)

        call_poller
      end

      it "displays a warning" do
        should have_selector "#evidence-updated-alert"
      end
    end

    describe "and someone deletes that Evidence" do
      before do
        @evidence.destroy
        track_destroyed(@evidence, @other_user)
        call_poller
      end

      it "displays a warning" do
        should have_selector "#evidence-deleted-alert"
      end
    end

    describe "and someone updates then deletes that evidence" do
      before do
        @evidence.update_attributes(content: "whatever")
        track_updated(@evidence, @other_user)
        @evidence.destroy
        track_destroyed(@evidence, @other_user)
        call_poller
      end

      it "displays a warning" do
        # Make sure the 'update' actions pointing to a no-longer-existent
        # Evidence don't crash the poller!
        should have_selector "#evidence-deleted-alert"
      end
    end
  end

  before do
    login_as_user
    @other_user = create(:user)
    @node     = create(:node)
    @evidence = create(:evidence, node: @node)
  end

  describe "when I am viewing an Evidence" do
    before { visit node_evidence_path(@node, @evidence) }
    it_behaves_like "an evidence page with poller"
  end

  describe "when I am editing an Evidence" do
    before { visit edit_node_evidence_path(@node, @evidence) }
    it_behaves_like "an evidence page with poller"
  end
end
