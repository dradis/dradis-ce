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

  example "merging with another node" do
    within_merge_node_modal do
      click_link @other_node.label
      click_button "Merge"
    end

    expect(current_path).to eq project_node_path(current_project, @node)
  end

  def within_merge_node_modal
    within("#modal_merge_node") { yield }
  end

  def click_node_toggle_button(node)
    find("[data-node-id='#{node.id}']").click
  end
end
