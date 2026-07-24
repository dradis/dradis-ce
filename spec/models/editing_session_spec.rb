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
        started_at: EditingSession.stale_after.ago - 1.minute
      )

      expect(EditingSession.for_record(issue).active).to eq([fresh_session])
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
        started_at: EditingSession.stale_after.ago - 1.minute
      )
      other_issue = create(:issue, node: project.issue_library)
      stale_elsewhere = create(:editing_session,
        user: other_user,
        record_type: 'Issue',
        record_id: other_issue.id,
        started_at: EditingSession.stale_after.ago - 1.minute
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
        started_at: EditingSession.stale_after.ago - 1.minute
      )

      EditingSession.acquire(record_type: 'Issue', record_id: issue.id, user: user)

      expect(EditingSession.where(id: stale.id)).not_to exist
    end
  end

  describe '.stale_after' do
    it 'defaults to 1 day' do
      expect(EditingSession.stale_after).to eq(1.day)
    end

    it 'is configurable instance-wide via Configuration' do
      Configuration.find_or_create_by(name: 'admin:editing_session_stale_after').update(value: 30)

      expect(EditingSession.stale_after).to eq(30.minutes)
    end
  end

  describe 'unique constraint' do
    it 'prevents duplicate sessions for the same user and record at the database level' do
      create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)

      duplicate = EditingSession.new(user: user, record_type: 'Issue', record_id: issue.id)
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
