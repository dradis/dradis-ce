require 'rails_helper'

describe EditingSession do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:project) { Project.new }
  let(:issue) { create(:issue, node: project.issue_library) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:record) }
  end

  describe '#record' do
    it 'resolves the polymorphic association from record_type and record_id' do
      session = create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)

      expect(session.record).to eq(issue)
    end
  end

  describe 'validations' do
    subject { create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id) }
    it { is_expected.to validate_presence_of(:record_type) }
  end

  describe '.for_record' do
    it 'returns sessions for the given record' do
      session = create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)
      other_issue = create(:issue, node: project.issue_library)
      create(:editing_session, user: user, record_type: 'Issue', record_id: other_issue.id)

      expect(EditingSession.for_record(issue)).to eq([session])
    end
  end

  describe '.by_others' do
    it 'excludes sessions belonging to the given user' do
      create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)
      other_session = create(:editing_session, user: other_user, record_type: 'Issue', record_id: issue.id)

      expect(EditingSession.for_record(issue).by_others(user)).to eq([other_session])
    end
  end

  describe '.active' do
    it 'excludes sessions older than the staleness threshold' do
      fresh_session = create(:editing_session,
        user: user,
        record_type: 'Issue',
        record_id: issue.id,
        started_at: 1.minute.ago
      )
      create(:editing_session,
        user: other_user,
        record_type: 'Issue',
        record_id: issue.id,
        started_at: EditingSession::STALE_AFTER.ago - 1.minute
      )

      expect(EditingSession.for_record(issue).active).to eq([fresh_session])
    end
  end

  describe '.parse_stream_name' do
    it 'extracts the record type and id from a stream name' do
      match = EditingSession.parse_stream_name("editing_presence_#{user.id}_Issue_#{issue.id}")

      expect(match[:record_type]).to eq('Issue')
      expect(match[:record_id]).to eq(issue.id.to_s)
    end

    it 'returns nil for a stream name with an unexpected shape' do
      expect(EditingSession.parse_stream_name('not_a_presence_stream')).to be_nil
    end
  end

  describe '.purge_stale_for' do
    it 'destroys stale sessions for the given record only' do
      fresh_session = create(:editing_session,
        user: user,
        record_type: 'Issue',
        record_id: issue.id,
        started_at: 1.minute.ago
      )
      create(:editing_session,
        user: other_user,
        record_type: 'Issue',
        record_id: issue.id,
        started_at: EditingSession::STALE_AFTER.ago - 1.minute
      )
      other_issue = create(:issue, node: project.issue_library)
      stale_elsewhere = create(:editing_session,
        user: other_user,
        record_type: 'Issue',
        record_id: other_issue.id,
        started_at: EditingSession::STALE_AFTER.ago - 1.minute
      )

      EditingSession.purge_stale_for(record_type: 'Issue', record_id: issue.id)

      expect(EditingSession.all).to contain_exactly(fresh_session, stale_elsewhere)
    end
  end

  describe '.acquire' do
    it 'creates a session for the user and record' do
      session = EditingSession.acquire(record_type: 'Issue', record_id: issue.id, user: user)

      expect(session).to be_persisted
      expect(EditingSession.where(user: user, record_type: 'Issue', record_id: issue.id)).to exist
    end

    it 'returns the existing session instead of raising when one already exists' do
      existing = create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)

      session = EditingSession.acquire(record_type: 'Issue', record_id: issue.id, user: user)

      expect(session).to eq(existing)
    end

    it 'purges stale sessions for the record before acquiring' do
      stale = create(:editing_session,
        user: other_user,
        record_type: 'Issue',
        record_id: issue.id,
        started_at: EditingSession::STALE_AFTER.ago - 1.minute
      )

      EditingSession.acquire(record_type: 'Issue', record_id: issue.id, user: user)

      expect(EditingSession.where(id: stale.id)).not_to exist
    end
  end

  describe 'unique constraint' do
    it 'prevents duplicate sessions for the same user and record at the database level' do
      create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)

      duplicate = EditingSession.new(user: user, record_type: 'Issue', record_id: issue.id)
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'presence broadcasting' do
    include ActionCable::TestHelper

    it 'broadcasts to other editors when a session is created' do
      create(:editing_session, user: other_user, record_type: 'Issue', record_id: issue.id)

      expect {
        create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)
      }.to have_broadcasted_to("editing_presence_#{other_user.id}_Issue_#{issue.id}")
    end

    it 'broadcasts to remaining editors when a session is destroyed' do
      session = create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)
      create(:editing_session, user: other_user, record_type: 'Issue', record_id: issue.id)

      expect {
        session.destroy
      }.to have_broadcasted_to("editing_presence_#{other_user.id}_Issue_#{issue.id}")
    end

    it 'does not issue an extra query per sibling' do
      session = create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)
      create(:editing_session, user: other_user, record_type: 'Issue', record_id: issue.id)
      create(:editing_session, user: create(:user), record_type: 'Issue', record_id: issue.id)

      editing_session_queries = 0
      counter = lambda do |*, payload|
        editing_session_queries += 1 if payload[:sql].include?('FROM "editing_sessions"')
      end

      ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') do
        session.send(:broadcast_presence)
      end

      expect(editing_session_queries).to eq(1)
    end
  end
end
