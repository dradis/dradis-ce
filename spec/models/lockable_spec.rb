require 'rails_helper'

describe Lockable do
  let(:user) { create(:user) }
  let(:project) { create(:project) }
  let(:issue) { create(:issue, node: project.issue_library) }

  describe '.allowed_types' do
    it 'includes models that have included the concern' do
      Issue # allowed_types is only populated once the model is autoloaded

      expect(Lockable.allowed_types).to include('Issue')
    end
  end

  describe '#editing_sessions' do
    it 'returns the sessions stored under the record\'s own class name' do
      session = create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)

      expect(issue.editing_sessions).to eq([session])
    end
  end

  describe '#acquire_edit_session' do
    it 'creates a session under the record\'s own class name' do
      issue.acquire_edit_session(user)

      expect(EditingSession.where(record_type: 'Issue', record_id: issue.id, user: user)).to exist
    end
  end

  describe '#release_edit_session' do
    it 'destroys the given user\'s session for the record' do
      create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)

      expect { issue.release_edit_session(user) }.to change { EditingSession.count }.by(-1)
    end

    it 'leaves another user\'s session for the record alone' do
      other_user = create(:user)
      session = create(:editing_session, user: other_user, record_type: 'Issue', record_id: issue.id)

      issue.release_edit_session(user)

      expect(EditingSession.all).to eq([session])
    end
  end

  describe 'destroying the record' do
    it 'destroys its editing sessions' do
      create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)

      expect { issue.destroy }.to change { EditingSession.count }.by(-1)
    end

    it 'leaves sessions for other records alone' do
      other_issue = create(:issue, node: project.issue_library)
      create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)
      other_session = create(:editing_session, user: user, record_type: 'Issue', record_id: other_issue.id)

      issue.destroy

      expect(EditingSession.all).to eq([other_session])
    end
  end
end
