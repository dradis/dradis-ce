require "spec_helper"

describe "moving a note", js: true do

  subject { page }

  before do
    login_to_project_as_user
 
    @note_0 = create_note
    # We're specifying the node label so the notes don't get assigned to the
    # same node
    @note_1 = create_note(node: create_node(label: "OtherNode-#{Time.now}"))
  end

  before do
    visit node_note_path(current_note.node, current_note)
    click_link "move"
  end

  let(:current_note) { @note_0 }

  example "moving a note to another node" do
    within_move_note_modal do
      click_link @note_1.node.label
      click_button "Move"
    end
    expect(@note_0.reload.node).to eq @note_1.node
    expect(current_path).to eq node_note_path(@note_0.node, @note_0)
  end

  def create_note(attrs={})
    create(:note, attrs)
  end

  def create_node(attrs={})
    create(:node, attrs)
  end
  
  def within_move_note_modal
    within("#modal_move_note") { yield }
  end
end
