require 'rails_helper'

describe 'Methodology Summary', js: true do
  subject { page }

  before do
    login_to_project_as_user

    methodology_lib = current_project.methodology_library

    @board1 = create(:board, project: current_project, node: methodology_lib)
    @list1 = create(:list, board: @board1)
    create(:card, list: @list1)

    @board2 = create(:board, project: current_project, node: methodology_lib)
    @list2 = create(:list, board: @board2)
    create(:card, list: @list2)
  end

  describe 'when in the projects show view' do
    it 'should display the methodology charts' do
      visit project_path(current_project)

      [@board1, @board2].each do |board|
        # 2 svg's: graph and its legend
        expect(all("#methodology-board-#{board.id} svg").count).to eq 2
      end
    end

    it 'only displays the project-level boards' do
      node = create(:node, project: current_project)
      node_board = create(:board, project: current_project, node: node)
      list3 = create(:list, board: node_board)
      create(:card, list: list3)

      visit project_path(current_project)

      expect(all("#methodology-board-#{node_board.id} svg").count).to eq 0
    end
  end
end
