require 'rails_helper'

describe 'Board pages:' do
  subject { page }

  it 'should require authenticated users' do
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

      context 'creating a board using a template', js: true do
        it 'creates the board using the template data' do
          template_path = Rails.root.join('spec/fixtures/files/methodologies/')
          allow(Methodology).to receive(:pwd).and_return(template_path)

          board
          visit project_boards_path(current_project)

          expect {
            click_link 'New Methodology'

            find('#modal-board-new', visible: true)
            find('#board_new_board_template ~ .combobox').click
            find('.combobox-option', text: 'Methodology Template v3').click
            click_button 'Add methodology'
          }.to change { Board.count }.by(1)
        end
      end
    end

    describe 'when in show page' do
      let(:board_path) { project_board_path(current_project, board) }

      include_examples 'managing lists'
    end
  end
end
