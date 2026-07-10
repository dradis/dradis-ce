require 'rails_helper'

describe EditingPresenceChannel, type: :channel do
  let(:user) { create(:user) }
  let(:project) { Project.new }
  let(:issue) { create(:issue, node: project.issue_library) }
  let(:stream_name) { "editing_presence_#{user.id}_Issue_#{issue.id}" }
  let(:signed_stream_name) { EditingPresenceChannel.signed_stream_name(stream_name) }

  before do
    stub_connection(current_user: user)
  end

  describe '#subscribed' do
    it 'streams from the verified stream name' do
      subscribe(signed_stream_name: signed_stream_name)

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from(stream_name)
    end

    it 'creates an editing session for the record encoded in the stream name' do
      subscribe(signed_stream_name: signed_stream_name)

      expect(
        EditingSession.where(user: user, record_type: 'Issue', record_id: issue.id)
      ).to exist
    end

    it 'rejects the subscription when the signed stream name is missing' do
      subscribe(signed_stream_name: nil)

      expect(subscription).to be_rejected
    end

    it 'rejects the subscription when the signed stream name is tampered with' do
      subscribe(signed_stream_name: "#{signed_stream_name}-tampered")

      expect(subscription).to be_rejected
    end

    it 'rejects the subscription when the record does not exist' do
      missing_stream_name = "editing_presence_#{user.id}_Issue_999999999"
      subscribe(signed_stream_name: EditingPresenceChannel.signed_stream_name(missing_stream_name))

      expect(subscription).to be_rejected
    end

    it 'rejects the subscription when the user is not authorized to read the record' do
      other_user = create(:user)
      unauthorized_stream_name = "editing_presence_#{user.id}_User_#{other_user.id}"
      subscribe(signed_stream_name: EditingPresenceChannel.signed_stream_name(unauthorized_stream_name))

      expect(subscription).to be_rejected
    end

    it 'purges stale sessions left by other editors of the same record' do
      other_user = create(:user)
      create(:editing_session,
        user: other_user,
        record_type: 'Issue',
        record_id: issue.id,
        started_at: EditingSession::STALE_AFTER.ago - 1.minute
      )

      subscribe(signed_stream_name: signed_stream_name)

      expect(EditingSession.where(user: other_user)).not_to exist
    end
  end

  describe '#unsubscribed' do
    it 'destroys the editing session for the user' do
      create(:editing_session,
        user: user,
        record_type: 'Issue',
        record_id: issue.id
      )

      subscribe(signed_stream_name: signed_stream_name)
      subscription.unsubscribe_from_channel

      expect(EditingSession.where(user: user, record_type: 'Issue', record_id: issue.id)).not_to exist
    end

    it 'does not fail when no session exists' do
      subscribe(signed_stream_name: signed_stream_name)

      expect {
        subscription.unsubscribe_from_channel
      }.not_to raise_error
    end
  end
end
