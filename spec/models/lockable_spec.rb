require 'rails_helper'

describe Lockable do
  let(:user) { create(:user) }
  let(:project) { Project.new }
  let(:issue) { create(:issue, node: project.issue_library) }

  describe '.allowed_types' do
    it 'includes models that have included the concern' do
      expect(Lockable.allowed_types).to include('Issue')
    end
  end

  describe '#editing_sessions' do
    it 'returns the sessions stored under the record\'s own class name' do
      session = create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)

      expect(issue.editing_sessions).to eq([session])
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
