require "spec_helper"

describe "reassigning a note", js: true do
  subject { page }

  before do
    login_to_project_as_user

    @node_0 = create_node(label: "Node 0")
    @node_1 = create_node(label: "Node 1")
    @node_2 = create_node(label: "Node 2", parent: @node_0)

    @note = create(:note, node: @node_0, updated_at: 2.seconds.ago)

    visit node_note_path(@node_0, @note)

    within_note_content do
      click_link "Move"
    end
  end

  describe "reassigning a note to another node" do
    it "reassigns the note" do
      within_move_note_modal do
        click_link @node_1.label
        click_button "Move"
      end

      expect(@note.reload.node_id).to eq @node_1.id
      expect(current_path).to eq node_note_path(@node_1, @note)
    end
  end

  describe "selecting the current node" do
    it "doesn't allow you to submit the form" do
      within_move_note_modal do
        click_link @node_0.label
      end

      expect(submit_move_button[:disabled]).to be true
    end
  end

  # unlike nodes notes should be able to move to child nodes
  describe "selecting a descendant of the current node" do
    it "reassigns the note" do
      within_move_note_modal do
        click_node_toggle_button(@node_0)
        click_link @node_2.label
        click_button "Move"
      end

      expect(@note.reload.node_id).to eq @node_2.id
      expect(current_path).to eq node_note_path(@node_2, @note)
    end
  end

  def create_node(attrs={})
    create(:node, attrs)
  end

  def within_note_content
    within(".note-actions") { yield }
  end

  def within_move_note_modal
    within("#modal_move_note") { yield }
  end

  def click_node_toggle_button(node)
    find("#modal_move_note [data-node-id='#{node.id}'] > a.toggle").click
  end

  def submit_move_button
    find("#modal_move_note .btn-primary")
  end
end
