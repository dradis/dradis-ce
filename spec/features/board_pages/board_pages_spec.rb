require 'rails_helper'

describe 'Board pages:' do
  subject { page }

  it 'should require authenticated users' do
    Configuration.create(name: 'admin:password', value: 'rspec_pass')
    visit project_boards_path(create(:project))
    expect(current_path).to eq(login_path)
    expect(page).to have_content('Access denied.')
  end

  context 'as authenticated user' do
    before { login_to_project_as_user }

    let(:board) do
      create(
        :board,
        node: current_project.methodology_library,
        project: current_project
      )
    end

    describe 'when in index page' do

      let(:boards_path) { project_boards_path(current_project) }
      let(:board_path) { project_board_path(current_project, Board.last) }

      include_examples 'managing boards'

      it 'only displays global boards' do
        board
        node = create(:node, project: current_project)
        node_board = create(:board, project: current_project, node: node)

        visit project_boards_path(current_project)

        expect(page).to have_text board.name
        expect(page).not_to have_text node_board.name
      end
    end
  end
end
