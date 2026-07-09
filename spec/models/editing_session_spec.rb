require 'rails_helper'

describe EditingSession do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:project) { Project.new }
  let(:issue) { create(:issue, node: project.issue_library) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id) }
    it { is_expected.to validate_presence_of(:record_type) }
    it { is_expected.to validate_presence_of(:record_id) }
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

  describe 'unique constraint' do
    it 'prevents duplicate sessions for the same user and record' do
      create(:editing_session, user: user, record_type: 'Issue', record_id: issue.id)

      duplicate = EditingSession.new(user: user, record_type: 'Issue', record_id: issue.id)
      expect(duplicate).not_to be_valid
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
  end
end
