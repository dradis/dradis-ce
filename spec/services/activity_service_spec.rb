require 'rails_helper'

describe ActivityService do
  before { described_class.subscribe_namespace('test') }

  let(:user) { create(:user) }
  let(:project) { create(:project) }

  let(:payload) {
    {
      action: 'test',
      project: {
        id: project.id
      },
      id: 1,
      class: 'Issue',
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    }
  }

  it 'enqueues ActivityTrackingJob for subscribed events' do
    expect do
      ActiveSupport::Notifications.instrument('test.event', payload)
    end.to have_enqueued_job(ActivityTrackingJob).with(
      action: payload[:action],
      project_id: project.id,
      trackable_id: payload[:id],
      trackable_type: 'Issue',
      user_id: user.id
    )
  end
end
