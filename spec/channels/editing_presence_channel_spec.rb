require 'rails_helper'

describe EditingPresenceChannel, type: :channel do
  let(:user) { create(:user) }
  let(:project) { Project.new }
  let(:issue) { create(:issue, node: project.issue_library) }

  before do
    stub_connection(current_user: user)
  end

  describe '#subscribed' do
    it 'streams from the record-specific channel' do
      subscribe(record_type: 'Issue', record_id: issue.id)

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("editing:Issue:#{issue.id}")
    end
  end

  describe '#unsubscribed' do
    it 'destroys the editing session for the user' do
      create(:editing_session,
        user: user,
        record_type: 'Issue',
        record_id: issue.id
      )

      subscribe(record_type: 'Issue', record_id: issue.id)
      subscription.unsubscribe_from_channel

      expect(EditingSession.where(user: user, record_type: 'Issue', record_id: issue.id)).not_to exist
    end

    it 'does not fail when no session exists' do
      subscribe(record_type: 'Issue', record_id: issue.id)

      expect {
        subscription.unsubscribe_from_channel
      }.not_to raise_error
    end
  end
end
