require 'rails_helper'

describe 'move position' do
  shared_examples 'validates previous id' do
    it 'prevents request with empty prev id' do
      subject
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'moves position with empty prev id and next id' do
      params.merge!(next_id:)
      subject
      expect(response).to have_http_status(:success)
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
  let(:list_1) { create(:list, board:) }
  let(:list_2) { create(:list, board:, previous_id: list_1.id) }

  context 'lists' do
    let(:params) { { prev_id: nil } }
    let(:next_id) { list_2.id }
    subject do
      post move_project_board_list_path(current_project, board, list_1), params:
    end

    include_examples 'validates previous id'
  end

  context 'cards' do
    let(:card_1) { create(:card, list_id: list_1.id) }
    let(:card_2) { create(:card, list_id: list_1.id) }
    let(:params) { { prev_id: nil } }
    let(:next_id) { card_2.id }
    subject do
      post move_project_board_list_card_path(current_project, board, list_1, card_1), params:
    end

    include_examples 'validates previous id'
  end
end
