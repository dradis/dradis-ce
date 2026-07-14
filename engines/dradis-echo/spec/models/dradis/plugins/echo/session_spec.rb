require 'rails_helper'
require File.expand_path('../../../../factories/providers', __dir__)
require File.expand_path('../../../../factories/agents', __dir__)
require File.expand_path('../../../../factories/sessions', __dir__)
require File.expand_path('../../../../factories/messages', __dir__)

describe Dradis::Plugins::Echo::Session do
  describe 'relationships' do
    it { should belong_to(:agent) }
    it { should belong_to(:record) }
    it { should belong_to(:user).optional }
    it { should have_many(:messages).dependent(:destroy) }
  end

  describe 'enum' do
    it 'defaults to idle' do
      expect(build(:echo_session).status).to eq('idle')
    end

    it { should define_enum_for(:status).with_values(%i[idle generating]) }
  end

  # Issue descends from Note without STI, so the default polymorphic setter
  # would store 'Note'. See Session#record= and Comment#commentable=.
  describe 'record=' do
    it 'stores an Issue as record_type Issue' do
      issue = create(:issue)
      session = create(:echo_session, record: issue)

      expect(session.reload.record_type).to eq('Issue')
      expect(session.record).to eq(issue)
    end

    it 'stores a Note as record_type Note' do
      note = create(:note)
      session = create(:echo_session, record: note)

      expect(session.reload.record_type).to eq('Note')
    end
  end

  describe '#project' do
    it 'delegates to the record' do
      note = create(:note)
      session = create(:echo_session, record: note)

      expect(session.project).to eq(note.project)
    end
  end

  describe '#to_provider_messages' do
    it 'returns role/content hashes ordered by creation' do
      session = create(:echo_session)
      create(:echo_message, session: session, role: :user, content: 'First')
      create(:assistant_message, session: session, content: 'Second')

      expect(session.to_provider_messages).to eq([
        { role: 'user', content: 'First' },
        { role: 'assistant', content: 'Second' }
      ])
    end
  end

  describe '.for_record' do
    it 'matches an Issue by its forced Issue type' do
      issue = create(:issue)
      session = create(:echo_session, record: issue)
      create(:echo_session, record: create(:note))

      expect(described_class.for_record(issue)).to eq([session])
    end
  end

  describe 'destroying the user' do
    it 'nullifies the user on its sessions and messages' do
      user = create(:user)
      session = create(:echo_session, user: user)
      message = create(:echo_message, session: session, user: user)

      user.destroy

      expect(session.reload.user_id).to be_nil
      expect(message.reload.user_id).to be_nil
    end
  end

  describe 'destroying the record' do
    it 'destroys sessions attached to a destroyed Note' do
      note = create(:note)
      session = create(:echo_session, record: note)

      expect { note.destroy }.to change { described_class.exists?(session.id) }.to(false)
    end

    it 'destroys sessions attached to a destroyed Issue' do
      issue = create(:issue)
      session = create(:echo_session, record: issue)

      expect { issue.destroy }.to change { described_class.exists?(session.id) }.to(false)
    end
  end
end
