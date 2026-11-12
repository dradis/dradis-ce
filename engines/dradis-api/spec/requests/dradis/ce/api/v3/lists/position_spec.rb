require 'rails_helper'

describe 'List positions API' do
  include_context 'project scoped API'
  include_context 'https'
  include_context 'content_type: application/json'
  include_context 'authorized API user'

  let(:board) { create(:board, project: current_project) }
  let!(:first) { create(:list, board: board) }
  let!(:list) { create(:list, board: board, previous_id: first.id) }
  let(:url) { "/api/boards/#{board.id}/lists/#{list.id}/position" }

  it 'reorders the lists and returns the list with its cards and position' do
    card = create(:card, list: list)
    put url, params: { next_id: first.id }.to_json, env: @env
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body).to include('id' => list.id, 'previous_id' => nil)
    expect(body['cards'].first['id']).to eq(card.id)
    expect(Board.find(board.id).ordered_lists).to eq([list, first])
  end

  it 'rejects an invalid position without changing the order' do
    put url, params: { prev_id: list.id }.to_json, env: @env
    expect(response).to have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)['errors']).to have_key('base')
    expect(Board.find(board.id).ordered_lists).to eq([first, list])
  end
end
