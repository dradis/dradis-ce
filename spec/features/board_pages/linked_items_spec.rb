require 'rails_helper'

describe "Linked items", js: true do
  subject { page }

  before do
    login_to_project_as_user

    @board = create(:board, project: current_project, node: current_project.methodology_library)
    @list1 = create(:list, board: @board)
  end

  describe "showing linked Lists in the board show page" do
    before do
      @list3 = create(:list, board: @board, previous_id: @list1.id)
      @list2 = create(:list, board: @board, previous_id: @list3.id)

      visit project_board_path(current_project, @board)
    end

    it "is in order" do
      # The last .list item is the Add new list link.
      lists = all("li.list")[0..2]
      expect(lists.count).to eq(3)
      expected_elements = [
        find("li.list[data-list-id='#{@list1.id}']"),
        find("li.list[data-list-id='#{@list3.id}']"),
        find("li.list[data-list-id='#{@list2.id}']")
      ]

      lists.each_with_index do |list, i|
        expect(list).to eq(expected_elements[i])
      end
    end
  end

  describe "showing linked Cards in the board show page" do
    before do
      @card1 = create(:card, list: @list1)
      @card3 = create(:card, list: @list1, previous_id: @card1.id)
      @card2 = create(:card, list: @list1, previous_id: @card3.id)

      visit project_board_path(current_project, @board)
    end

    it "is in order" do
      cards = all("li.card")
      expected_elements = [
        find("li.card[data-card-id='#{@card1.id}']"),
        find("li.card[data-card-id='#{@card3.id}']"),
        find("li.card[data-card-id='#{@card2.id}']"),
      ]

      cards.each_with_index do |card, i|
        expect(card).to eq(expected_elements[i])
      end
    end
  end
end
