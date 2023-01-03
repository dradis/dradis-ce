require 'rails_helper'

describe 'move position' do
  shared_examples 'validates move params' do
    it 'prevents request with empty prev id' do
      subject
      expect(response).to redirect_to(project_board_path(current_project, board))
      expect(flash[:alert]).to eq('Something fishy is going on...')
    end
    it 'prevents request with empty prev id' do
      params.merge!(next_id: nil)
      subject
      expect(response).to redirect_to(project_board_path(current_project, board))
      expect(flash[:alert]).to eq('Something fishy is going on...')
    end
    it 'prevents request with invalid prev id' do
      params.merge!(prev_id: invalid_prev_id)
      subject
      expect(response).to redirect_to(project_board_path(current_project, board))
      expect(flash[:alert]).to eq('Something fishy is going on...')
    end
    it 'prevents request with invalid next id' do
      params.merge!(prev_id: invalid_next_id)
      subject
      expect(response).to redirect_to(project_board_path(current_project, board))
      expect(flash[:alert]).to eq('Something fishy is going on...')
    end
  end

  before { login_to_project_as_user }

  let(:board) do
    create(
      :board,
      node: current_project.methodology_library,
      project: current_project
    )
  end
  let(:list_1) { create(:list, board: board) }
  let(:list_2) { create(:list, board: board, previous_id: list_1.id) }
  let(:another_board) do
    create(
      :board,
      node: current_project.methodology_library,
      project: current_project
    )
  end
  let(:another_list) { create(:list, board: another_board) }

  context 'lists' do
    let(:params) { { prev_id: nil } }
    let(:invalid_prev_id) { another_list.id }
    let(:invalid_next_id) { another_list.id }
    subject do
      post move_project_board_list_path(current_project, board, list_2), params: params
    end

    include_examples 'validates move params'
  end

  context 'cards' do
    let(:card_1) { create(:card, list_id: list_1.id) }
    let(:card_2) { create(:card, list_id: list_1.id) }
    let(:another_card) { create(:card, list_id: another_list.id) }
    let(:params) { { prev_id: nil } }
    let(:invalid_prev_id) { another_card.id }
    let(:invalid_next_id) { another_card.id }
    subject do
      post move_project_board_list_card_path(current_project, board, list_1, card_1), params: params
    end

    include_examples 'validates move params'
  end
end
