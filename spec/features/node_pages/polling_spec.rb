require "spec_helper"

describe "node pages", js: true do
  include ActivityMacros

  subject { page }

  before do
    login_to_project_as_user
    @other_user = create(:user)
    @node       = create(:node)
    @note_0     = create(:note, node: @node, text:"#[Title]#\nNote 0")
    @note_1     = create(:note, node: @node, text:"#[Title]#\nNote 1")
    @evidence_0 = create(:evidence, node: @node, content:"#[Title]#\nEv 0")
    @evidence_1 = create(:evidence, node: @node, content:"#[Title]#\nEv 1")
  end

  describe "when another user adds a new node to the current project" do
    context "and the new node is a root node" do
      before do
        visit node_path(@node)
        @new_node = create(:node, label: "New node", parent_id: nil)
      end

      let(:add_node) do
        track_created(@new_node, @other_user)
        call_poller
      end

      it "adds it to the sidebar" do
        within_main_sidebar do
          should have_no_selector node_link_selector(@new_node)
          add_node
          should have_selector node_link_selector(@new_node), text: "New node"
        end
      end

      it "adds it to the 'move node' modal" do
        show_move_node_modal
        within_move_node_nodal do
          should have_no_selector node_link_selector(@new_node)
          add_node
          should have_selector node_link_selector(@new_node)
        end
      end
    end

    context "and the new node is a subnode" do
      before do
        # Give the node another subnode so it's expandable:
        create(:node, label: "Other Sub", parent: @node)
        visit node_path(@node)
      end

      context "and its parent is visible" do
        context "in the sidebar" do
          before { expand_node_in_sidebar(@node) }

          it "adds the node to the sidebar" do
            within_main_sidebar do
              should have_selector node_link_selector(@node)
              @subnode = create(:node, label: "Sub", parent: @node)
              should have_no_selector node_link_selector(@subnode)
              track_created(@subnode, @other_user)
              call_poller
              should have_selector node_link_selector(@subnode)
            end
          end
        end

        context "in the 'move node' modal" do
          before do
            show_move_node_modal
            expand_node_in_modal(@node)
          end

          it "adds the node to the sidebar" do
            within_move_node_nodal do
              should have_selector node_link_selector(@node)
              @subnode = create(:node, label: "Sub", parent: @node)
              should have_no_selector node_link_selector(@subnode)
              track_created(@subnode, @other_user)
              call_poller
              should have_selector node_link_selector(@subnode)
            end
          end
        end
      end

      context "and its parent has no other subnodes" do
        specify "the 'expand' link appears, and works" do
          @sub = create(:node, label: "Sub", parent: @node)
          track_created(@sub, @other_user)
          call_poller
          within_main_sidebar do
            should have_selector "#{node_li_selector(@node)} > a.toggle"
            expand_node_in_sidebar(@node)
            should have_selector node_link_selector(@sub), text: "Sub"
          end
        end
      end
    end
  end

  describe "when another user deletes the current node" do
    before { visit node_path(@node) }

    it "displays a warning" do
      @node.destroy
      track_destroyed(@node, @other_user)
      call_poller

      should have_selector "#node-deleted-alert"
    end
  end

  describe "when another user deletes a root node" do
    before do
      @other_node = create(:node, label: "Delete me")
      visit node_path(@node)
    end

    let(:delete_node) do
      @other_node.destroy
      track_destroyed(@other_node, @other_user)
      call_poller
    end

    it "is removed from the sidebar" do
      within_main_sidebar do
        should have_selector node_link_selector(@other_node), text: "Delete me"
        delete_node
        should have_no_selector node_link_selector(@other_node)
      end
    end

    it "is removed from the move node nodal" do
      show_move_node_modal
      within_move_node_nodal do
        should have_selector node_link_selector(@other_node)
        delete_node
        should have_no_selector node_link_selector(@other_node)
      end
    end
  end

  describe "when another user deletes a non-root node" do
    before do
      @subnode = create(:node, label: "Sub", parent: @node)
      visit node_path(@node)
    end

    let(:delete_node) do
      @subnode.destroy
      track_destroyed(@subnode, @other_user)
      call_poller
    end

    context "when it is not yet visible in the sidebar" do
      it "does not appear when the parent node is expanded in the sidebar" do
        within_main_sidebar do
          should have_no_selector node_link_selector(@subnode)
          delete_node
          expand_node_in_sidebar(@node)
          should have_no_content "Loading..." # Make sure loading is complete
          should have_no_selector node_link_selector(@subnode)
        end
      end
    end

    context "when it is not yet visible in the move node modal" do
      before { show_move_node_modal }

      it "does not appear when the parent node is expanded in the modal" do
        within_move_node_nodal do
          should have_no_selector node_link_selector(@subnode)
          delete_node
          expand_node_in_modal(@node)
          should have_no_content "Loading..." # Make sure loading is complete
          should have_no_selector node_link_selector(@subnode)
        end
      end
    end


    context "when it is visible in the sidebar" do
      before { expand_node_in_sidebar(@node) }

      it "is removed from the sidebar" do
        within_main_sidebar do
          should have_selector node_link_selector(@subnode), text: "Sub"
          delete_node
          should have_no_selector node_link_selector(@subnode)
        end
      end
    end


    context "when it is visible in the move node modal" do
      before do
        show_move_node_modal
        expand_node_in_modal(@node)
      end

      it "is removed from the move node nodal" do
        within_move_node_nodal do
          should have_selector node_link_selector(@subnode)
          delete_node
          should have_no_selector node_link_selector(@subnode)
        end
      end
    end
  end # when another user deletes a non-root node


  describe "when another user updates a node" do
    before do
      @other_node = create(:node, label: "Other")
      visit node_path(@node)
    end

    let(:update_node) do
      @other_node.update_attributes!(label: "New name")
      track_updated(@other_node, @other_user)
      call_poller
    end

    it "updates the link in the sidebar" do
      within_main_sidebar do
        should have_selector node_link_selector(@other_node), text: "Other"
        update_node
        should have_selector node_link_selector(@other_node), text: "New name"
      end
    end

    it "updates the link in the move node nodal" do
      show_move_node_modal
      within_move_node_nodal do
        should have_selector node_link_selector(@other_node), text: "Other"
        update_node
        should have_selector node_link_selector(@other_node), text: "New name"
      end
    end
  end # when another user updates a node

  def within_main_sidebar
    within(".main-sidebar") { yield }
  end

  def node_li_selector(node)
    "li.node[data-node-id='#{node.id}']"
  end

  def node_link_selector(node)
    "#{node_li_selector(node)} > a[href='#{node_path(node)}']"
  end

  def within_move_node_nodal
    within("#modal_move") { yield }
  end

  def show_move_node_modal
    click_link "Move" unless move_modal_visible?
  end

  def move_modal_visible?
    all("#modal_move", visible: true).any?
  end

  def wait_for_loading_to_finish
    safety = 0
    # The page will have .loading elements, but they start off hidden and only
    # get shown once loading actually takes place
    while page.has_selector?("li.node > ul > li.loading", visible: true)
      raise "Loading timed out" if (safety += 1) >= 60
      sleep 0.5
    end
  end

  def expand_node_in_sidebar(node)
    find(".main-sidebar [data-node-id='#{node.id}'] > .toggle").click
    wait_for_loading_to_finish
  end

  def expand_node_in_modal(node)
    find("#modal_move [data-node-id='#{node.id}'] > .toggle").click
    wait_for_loading_to_finish
  end

end
