require 'rails_helper'

describe "node pages", js: true do
  include ActivityMacros

  subject { page }

  before do
    login_to_project_as_user
    @other_user = create(:user)
    @node       = create(:node, project: current_project)
    @note_0     = create(:note, node: @node, text:"#[Title]#\nNote 0")
    @note_1     = create(:note, node: @node, text:"#[Title]#\nNote 1")
    issue       = create(:issue, node: current_project.issue_library)
    @evidence_0 = create(:evidence, issue: issue, node: @node, content:"#[Title]#\nEv 0")
    @evidence_1 = create(:evidence, issue: issue, node: @node, content:"#[Title]#\nEv 1")
  end

  describe "when another user adds a new node to the current project" do
    context "and the new node is a root node" do
      before do
        visit project_node_path(@node.project, @node)
        @new_node = create(:node, label: "New node", parent_id: nil, project: current_project)
      end

      let(:add_node) do
        create(:activity, action: :create, trackable: @new_node, user: @other_user)
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
        create(:node, label: "Other Sub", parent: @node, project: current_project)
        visit project_node_path(@node.project, @node)
      end

      context "and its parent is visible" do
        context "in the sidebar" do
          before { expand_node_in_sidebar(@node) }

          it "adds the node to the sidebar" do
            within_main_sidebar do
              should have_selector node_link_selector(@node)
              @subnode = create(:node, label: "Sub", parent: @node, project: current_project)
              should have_no_selector node_link_selector(@subnode)
              create(:activity, action: :create, trackable: @subnode, user: @other_user)
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
              @subnode = create(:node, label: "Sub", parent: @node, project: current_project)
              should have_no_selector node_link_selector(@subnode)
              create(:activity, action: :create, trackable: @subnode, user: @other_user)
              call_poller
              should have_selector node_link_selector(@subnode)
            end
          end
        end
      end

      context "and its parent has no other subnodes" do
        specify "the 'expand' link appears, and works" do
          @sub = create(:node, label: "Sub", parent: @node, project: current_project)
          create(:activity, action: :create, trackable: @sub, user: @other_user)
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
    before { visit project_node_path(@node.project, @node) }

    it "displays a warning" do
      @node.destroy
      create(:activity, action: :destroy, trackable: @node, user: @other_user)
      call_poller

      should have_selector "#node-deleted-alert"
    end
  end

  describe "when another user deletes a root node" do
    before do
      @other_node = create(:node, label: "Delete me", project: current_project)
      visit project_node_path(@node.project, @node)
    end

    let(:delete_node) do
      @other_node.destroy
      create(:activity, action: :destroy, trackable: @other_node, user: @other_user)
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
      @subnode = create(:node, label: "Sub", parent: @node, project: current_project)
      visit project_node_path(@node.project, @node)
    end

    let(:delete_node) do
      @subnode.destroy
      create(:activity, action: :destroy, trackable: @subnode, user: @other_user)
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
      @other_node = create(:node, label: "Other", project: current_project)
      visit project_node_path(@node.project, @node)
    end

    let(:update_node) do
      @other_node.update_attributes!(label: "New name")
      create(:activity, action: :update, trackable: @other_node, user: @other_user)
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
    find('.tree-header').click
    within(".main-sidebar") { yield }
  end

  def node_li_selector(node)
    "li.node[data-node-id='#{node.id}']"
  end

  def node_link_selector(node)
    "#{node_li_selector(node)} > a[href='#{project_node_path(node.project, node)}']"
  end

  def within_move_node_nodal
    within("#modal_move_node") { yield }
  end

  def show_move_node_modal
    if !move_modal_visible?
      find('[data-behavior~=nodes-more-dropdown]').click
      click_link 'Move'
    end
  end

  def move_modal_visible?
    all("#modal_move_node", visible: true).any?
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
    find('.tree-header').click
    find(".main-sidebar [data-node-id='#{node.id}'] > .toggle").click
    wait_for_loading_to_finish
  end

  def expand_node_in_modal(node)
    find("#modal_move_node [data-node-id='#{node.id}'] > .toggle").click
    wait_for_loading_to_finish
  end

end
