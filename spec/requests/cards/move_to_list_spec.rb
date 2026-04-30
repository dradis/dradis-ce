require 'rails_helper'

describe 'cards#move_to_list' do
  before { login_to_project_as_user }

  let(:board)       { create(:board, node: current_project.methodology_library, project: current_project) }
  let(:source_list) { create(:list, board: board) }
  let(:target_list) { create(:list, board: board, previous_id: source_list.id) }

  let(:card_a) { create(:card, list: source_list) }
  let(:card_b) { create(:card, list: source_list, previous_id: card_a.id) }
  let(:card_c) { create(:card, list: source_list, previous_id: card_b.id) }

  let(:last_card_in_target) { create(:card, list: target_list) }

  let(:submit) do
    post move_to_list_project_board_list_card_path(current_project, board, source_list, card_b),
      params: { new_list_id: target_list.id }
  end

  before do
    card_a
    card_b
    card_c
    last_card_in_target
  end

  it 'moves the card to the target list' do
    submit
    expect(card_b.reload.list).to eq(target_list)
  end

  it 'appends the card to the end of the target list' do
    submit
    expect(card_b.reload.previous_id).to eq(last_card_in_target.id)
  end

  it 'repairs the source list chain' do
    submit
    expect(card_c.reload.previous_id).to eq(card_a.id)
  end

  it 'redirects to the card in its new list with a notice' do
    submit
    expect(response).to redirect_to(project_board_list_card_path(current_project, board, target_list, card_b))
    expect(flash[:notice]).to eq('Task moved.')
  end

  it 'creates an activity' do
    expect { submit }.to have_enqueued_job(ActivityTrackingJob).with(
      action: 'update',
      project_id: current_project.id,
      trackable_id: card_b.id,
      trackable_type: 'Card',
      user_id: @logged_in_as.id
    )
  end

  context 'when the target list is empty' do
    let(:last_card_in_target) { nil }

    before { target_list }

    it 'makes the card the first item in the target list' do
      submit
      expect(card_b.reload.previous_id).to be_nil
    end
  end
end
