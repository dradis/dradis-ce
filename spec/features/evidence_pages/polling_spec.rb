require 'rails_helper'

describe "evidence pages", js: true do
  include ActivityMacros

  subject { page }

  shared_examples "an evidence page with poller" do
    describe "when someone else updates the current Evidence" do
      before do
        @evidence.update(content: "whatever")
        create(:activity, action: :update, trackable: @evidence, user: @other_user)

        call_poller
      end

      it "displays a warning" do
        should have_selector "#evidence-updated-alert"
      end
    end

    describe "and someone deletes that Evidence" do
      before do
        @evidence.destroy
        create(:activity, action: :destroy, trackable: @evidence, user: @other_user)
        call_poller
      end

      it "displays a warning" do
        should have_selector "#evidence-deleted-alert"
      end
    end

    describe "and someone updates then deletes that evidence" do
      before do
        @evidence.update(content: "whatever")
        create(:activity, action: :update, trackable: @evidence, user: @other_user)
        @evidence.destroy
        create(:activity, action: :destroy, trackable: @evidence, user: @other_user)
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
    login_to_project_as_user
    @other_user = create(:user)
    @node       = create(:node, project: @project)
    issue       = create(:issue, node: @project.issue_library)
    @evidence   = create(:evidence, node: @node, issue: issue)
  end

  describe "when I am viewing an Evidence" do
    before { visit project_node_evidence_path(current_project, @node, @evidence) }
    it_behaves_like "an evidence page with poller"
  end

  describe "when I am editing an Evidence" do
    before { visit edit_project_node_evidence_path(current_project, @node, @evidence) }
    it_behaves_like "an evidence page with poller"
  end
end
