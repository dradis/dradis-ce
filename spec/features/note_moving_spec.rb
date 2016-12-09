require "spec_helper"

describe "moving a note", js: true do

  subject { page }

  before do
    login_to_project_as_user

    # Tree:
    #
    # - node_0
    #   - node_2
    #     - node_5
    #   - node_3
    # - node_1
    #   - node_4
    @node_0 = create(:node, label: "Node 0")
    @node_1 = create(:node, label: "Node 1")
    @node_2 = create(:node, label: "Node 2", parent: @node_0)
    @node_3 = create(:node, label: "Node 3", parent: @node_0)
    @node_4 = create(:node, label: "Node 4", parent: @node_1)
    @node_5 = create(:node, label: "Node 5", parent: @node_2)

    visit node_note_path(@node_5, current_note)
    click_move_note
  end

  let(:current_note) { @note = create(:note, node: @node_5) }

  describe "moving a note to a different node" do
    before do
      within('#modal_move_note') do
        click_link @node_1.label
        click_submit
      end
    end

    it "should update the note's node_id" do
      expect(current_note.reload.node_id).to eq(@node_1.id)
    end

    it "should redirect to note show path" do
      expect(current_path).to eq(node_note_path(@node_1, current_note))
    end
  end

  describe "moving a note to a similar node" do
    before do
      within('#modal_move_note') do
        click_link @node_5.label
        click_submit
      end
    end

    it "should update the node as an invalid selection" do
      expect(find('.invalid-selection').text).to eq(@node_5.label)
    end
  end



  def click_move_note
    find("a[href='#modal_move_note']").click
  end

  def click_submit
    find('.btn-primary').click
  end

end
