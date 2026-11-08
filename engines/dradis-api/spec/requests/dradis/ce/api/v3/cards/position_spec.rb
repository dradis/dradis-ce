require 'rails_helper'

describe 'Card positions API' do
  include_context 'project scoped API'
  include_context 'https'
  include_context 'content_type: application/json'
  include_context 'authorized API user'

  let(:board) { create(:board, project: current_project) }
  let(:source) { create(:list, board: board) }
  let(:destination) { create(:list, board: board) }
  let!(:first) { create(:card, list: source) }
  let!(:card) { create(:card, list: source, previous_id: first.id) }
  let!(:last) { create(:card, list: source, previous_id: card.id) }
  let(:url) { "/api/boards/#{board.id}/lists/#{source.id}/cards/#{card.id}/position" }

  it 'moves the card between destination neighbors and repairs the source chain' do
    target_first = create(:card, list: destination)
    target_last = create(:card, list: destination, previous_id: target_first.id)
    put url, params: {
      new_list_id: destination.id, prev_id: target_first.id, next_id: target_last.id
    }.to_json, env: @env

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to include('list_id' => destination.id, 'previous_id' => target_first.id)
    expect(source.ordered_cards).to eq([first, last])
    expect(destination.ordered_cards).to eq([target_first, card, target_last])
  end

  it 'leaves the position unchanged and emits no activity when sent the current list' do
    expect do
      put url, params: { new_list_id: source.id }.to_json, env: @env
    end.not_to have_enqueued_job(ActivityTrackingJob)
    expect(response).to have_http_status(:ok)
    expect(source.ordered_cards).to eq([first, card, last])
  end

  it 'returns 404 for a destination on another board' do
    other_list = create(:list, board: create(:board, project: current_project))
    put url, params: { new_list_id: other_list.id }.to_json, env: @env
    expect(response).to have_http_status(:not_found)
    expect(card.reload.list).to eq(source)
  end

  it 'returns validation errors for a neighbor outside the destination' do
    put url, params: { new_list_id: destination.id, prev_id: first.id }.to_json, env: @env
    expect(response).to have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)['errors']).to have_key('base')
    expect(card.reload.list).to eq(source)
  end
end
