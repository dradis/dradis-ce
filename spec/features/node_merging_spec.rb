require 'rails_helper'

describe "merging a node", js: true do

  subject { page }

  before do
    login_to_project_as_user

    @node = create(:node, label: "Node", project: current_project)
    @other_node = create(:node, label: "Other Node", project: current_project)
  end

  before do
    visit project_node_path(@node.project, @node)
    click_link "Merge"
  end

  example "Clicking merge opens the modal" do
    expect(page).to have_selector('#modal_merge_node', visible: true)
  end

  describe "within the merge modal" do
    it "starts with Merge button disabled" do
      expect(page).to have_button('Merge', disabled: true)
    end

    it "selecting a node makes the Merge button enabled" do
      within_merge_node_modal do
        click_link @other_node.label
      end

      expect(page).to have_button('Merge', disabled: false)
    end

    it "selecting a node fills in the current selection text" do
      within_merge_node_modal do
        click_link @other_node.label
      end

      expect(find('#current-selection')).to have_content(@other_node.label)
    end

    it "clicking Merge button performs a merge" do
      within_merge_node_modal do
        click_link @other_node.label
        click_button "Merge"
      end

      expect(current_path).to eq project_node_path(current_project, @node)
      expect(page).to have_content("Successfully merged with #{@other_node.label}")
    end
  end

  def within_merge_node_modal
    within("#modal_merge_node") { yield }
  end

  def click_node_toggle_button(node)
    find("[data-node-id='#{node.id}']").click
  end
end
