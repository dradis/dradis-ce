require 'rails_helper'

describe "moving a node", js: true do

  subject { page }

  before do
    login_to_project_as_user

    @node_0 = create_node(label: "Node 0")
    @node_1 = create_node(label: "Node 1")
    @node_2 = create_node(label: "Node 2", parent: @node_0)
    @node_3 = create_node(label: "Node 3", parent: @node_0)
    @node_4 = create_node(label: "Node 4", parent: @node_1)
    @node_5 = create_node(label: "Node 4", parent: @node_2)

    # Tree:
    #
    # - node_0
    #   - node_2
    #     - node_5
    #   - node_3
    # - node_1
    #   - node_4

  end

  before do
    visit node_path(current_node)
    click_link "Move"
  end

  let(:current_node) { @node_2 }

  example "moving a node below another node" do
    within_move_node_modal do
      click_link @node_3.label
      click_button "Move"
    end
    expect(@node_2.reload.parent).to eq @node_3
    expect(current_path).to eq node_path(@node_2)
  end


  # Bug fix ;)
  example "moving a node below a sub-node of a different root node" do
    within_move_node_modal do
      click_node_toggle_button(@node_1)
      click_link @node_4.label
      click_button "Move"
    end

    expect(@node_2.reload.parent).to eq @node_4
    expect(current_path).to eq node_path(@node_2)
  end


  describe "selecting a descendant of the current node" do
    before do
      click_node_toggle_button(@node_2)
      click_link @node_5.label
    end

    it "doesn't allow you to submit the form" do
      expect(submit_move_button[:disabled]).to eq 'true'
    end
  end


  describe "selecting 'move to root'" do
    before { choose :node_move_destination_root }

    describe "and clicking 'Move'" do
      before do
        within_move_node_modal do
          click_button "Move"
        end
      end

      it "makes the node a root node" do
        expect(current_node.reload)
      end
    end

    describe "and clicking within the tree" do
      before do
        within_move_node_modal do
          click_node_toggle_button(@node_1)
          click_link @node_4.label
        end
      end

      it "selects the 'Move below node' radio button again" do
        root_radio_button = find("#node_move_destination_root")
        node_radio_button = find("#node_move_destination_node")
        expect(root_radio_button).not_to be_checked
        expect(node_radio_button).to be_checked
      end
    end
  end


  context "when moving a root node" do
    let(:current_node) { @node_0 }

    it "doesn't show the 'move to root' radio buttons" do
      within_move_node_modal do
        should_not have_field :node_move_destination_root
        should_not have_field :node_move_destination_node
      end
    end
  end


  def create_node(attrs={})
    create(:node, attrs)
  end

  def within_move_node_modal
    within("#modal_move_node") { yield }
  end

  def click_node_toggle_button(node)
    find("#modal_move_node [data-node-id='#{node.id}'] > a.toggle").click
  end

  def submit_move_button
    find("#modal_move_node .btn-primary")
  end


end
