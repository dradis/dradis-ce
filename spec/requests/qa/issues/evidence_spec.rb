require 'rails_helper'

describe 'QA Evidence state updates' do
  before do
    login_to_project_as_user
    allow_any_instance_of(Project).to receive(:reviewers).and_return(User.all)
    @subscription = ActiveSupport::Notifications.subscribe(/\Aevidence\.(state_change|updated)\z/) do |event|
      events << event
    end
  end

  after do
    ActiveSupport::Notifications.unsubscribe(@subscription)
  end

  let(:events) { [] }
  let(:issue) { create(:issue, node: current_project.issue_library, state: :ready_for_review) }
  let(:node) { create(:node, project: current_project) }
  let!(:evidence) { create(:evidence, issue: issue, node: node, state: :ready_for_review) }

  it 'publishes a state change and preserves the activity for a single update' do
    expect do
      patch project_qa_issue_evidence_path(current_project, issue, evidence), params: { state: 'published' }
    end.to have_enqueued_job(ActivityTrackingJob).with(
      action: 'state_change',
      project_id: current_project.id,
      trackable_id: evidence.id,
      trackable_type: 'Evidence',
      user_id: @logged_in_as.id
    )

    expect(response).to have_http_status(:redirect)
    expect(evidence.reload).to be_published
    expect(events.map(&:name)).to eq(['evidence.state_change'])
    expect(events.first.payload).to include(id: evidence.id, action: 'state_change', state: 'published')
  end

  it 'publishes one state change per selected record in a bulk update' do
    other_evidence = create(:evidence, issue: issue, node: node, state: :ready_for_review)
    untouched_evidence = create(:evidence, issue: issue, node: node, state: :ready_for_review)

    patch multiple_update_project_qa_issue_evidence_index_path(current_project, issue), params: {
      ids: [evidence.id, other_evidence.id], state: 'draft'
    }

    expect(response).to have_http_status(:redirect)
    expect(evidence.reload).to be_draft
    expect(other_evidence.reload).to be_draft
    expect(untouched_evidence.reload).to be_ready_for_review
    expect(events.map(&:name)).to eq(['evidence.state_change', 'evidence.state_change'])
    expect(events.map { |event| event.payload[:id] }).to match_array([evidence.id, other_evidence.id])
    expect(events.map { |event| event.payload[:action] }).to eq(['state_change', 'state_change'])
  end

  it 'rejects an invalid single state update without publishing an event' do
    patch project_qa_issue_evidence_path(current_project, issue, evidence), params: { state: 'unknown' }

    expect(response).to have_http_status(:redirect)
    expect(evidence.reload).to be_ready_for_review
    expect(events).to be_empty
  end

  it 'rejects an invalid bulk state update without publishing an event' do
    patch multiple_update_project_qa_issue_evidence_index_path(current_project, issue), params: {
      ids: [evidence.id], state: 'unknown'
    }

    expect(response).to have_http_status(:redirect)
    expect(evidence.reload).to be_ready_for_review
    expect(events).to be_empty
  end
end
