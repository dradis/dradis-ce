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
    it 'delegates to the record (the authorization seam)' do
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

    it 'excludes streaming and failed turns so no nil-content turn is replayed' do
      session = create(:echo_session)
      create(:echo_message, session: session, role: :user, content: 'First')
      create(:assistant_message, session: session, status: :streaming, content: nil)
      create(:assistant_message, session: session, status: :failed, content: nil)

      expect(session.to_provider_messages).to eq([
        { role: 'user', content: 'First' }
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

  describe '#request_reply!' do
    let(:session) { create(:echo_session) }

    before do
      allow(Dradis::Plugins::Echo::ReplyJob).to receive(:perform_later)
      allow_any_instance_of(described_class).to receive(:broadcast_composer_state)
    end

    it 'flips an idle session to generating and enqueues one reply' do
      expect { session.request_reply! }
        .to change { session.reload.status }.from('idle').to('generating')
      expect(Dradis::Plugins::Echo::ReplyJob)
        .to have_received(:perform_later).with(session).once
    end

    it 'broadcasts the composer state on the idle->generating transition' do
      expect(session).to receive(:broadcast_composer_state)
      session.request_reply!
    end

    it 'does not double-enqueue while already generating' do
      session.request_reply!
      session.request_reply!
      expect(Dradis::Plugins::Echo::ReplyJob).to have_received(:perform_later).once
    end

    context 'with a stale generating lock' do
      let(:read_timeout) { Dradis::Plugins::Echo::Provider::HttpStreaming::READ_TIMEOUT.seconds }

      before { session.update!(status: :generating) }

      it 'reclaims a streaming message stuck past the read timeout and re-enqueues' do
        stale = create(:assistant_message, session: session, status: :streaming, content: nil)
        stale.update_column(:updated_at, (read_timeout + described_class::STUCK_MARGIN + 1.minute).ago)

        session.request_reply!

        expect(session.reload).to be_generating
        expect(stale.reload).to be_failed
        expect(stale.metadata['error']).to eq(Dradis::Plugins::Echo::Message::GENERIC_ERROR)
        expect(Dradis::Plugins::Echo::ReplyJob).to have_received(:perform_later).once
      end

      it 'leaves a fresh generating lock alone' do
        create(:assistant_message, session: session, status: :streaming, content: nil)
        session.request_reply!
        expect(Dradis::Plugins::Echo::ReplyJob).not_to have_received(:perform_later)
      end

      it 'leaves a live stream touched within the threshold alone' do
        stale = create(:assistant_message, session: session, status: :streaming, content: nil)
        stale.update_column(:updated_at, (read_timeout - 1.minute).ago)

        session.request_reply!

        expect(stale.reload).to be_streaming
        expect(Dradis::Plugins::Echo::ReplyJob).not_to have_received(:perform_later)
      end

      it 'reclaims a generating session that has no streaming message once it is stale' do
        session.update_column(:updated_at, (read_timeout + described_class::STUCK_MARGIN + 1.minute).ago)

        session.request_reply!

        expect(session.reload).to be_generating
        expect(Dradis::Plugins::Echo::ReplyJob).to have_received(:perform_later).once
      end

      it 'leaves a freshly generating session with no streaming message alone' do
        session.touch
        session.request_reply!
        expect(Dradis::Plugins::Echo::ReplyJob).not_to have_received(:perform_later)
      end
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

    # The gap the Note-only after_destroy sweep (engine.rb) exists for: an Issue
    # row destroyed while loaded as a Note (e.g. a Pro project.notes cascade).
    # Loaded as Note, the polymorphic dependent: :destroy queries record_type
    # 'Note' and misses the session, so the record_type 'Issue' sweep catches it.
    it 'destroys record_type Issue sessions when the Issue row is destroyed loaded as a Note' do
      issue = create(:issue)
      session = create(:echo_session, record: issue)
      note = Note.find(issue.id)

      expect { note.destroy }.to change { described_class.exists?(session.id) }.to(false)
    end

    # Guards the bug fix: the Issue sweep lives on Note only (engine.rb), not in
    # the shared Sessionable concern. A future host with its own id sequence must
    # not delete an unrelated Issue #N's sessions. Model that host on the
    # categories table, sharing an id with a real Issue so the old in-concern
    # sweep would have wrongly deleted the Issue's session.
    it 'leaves unrelated Issue sessions alone when a non-Note Sessionable host is destroyed' do
      issue = create(:issue)
      issue_session = create(:echo_session, record: issue)

      host_class = Class.new(ApplicationRecord) do
        self.table_name = 'categories'
        def self.name = 'EchoSessionableTestHost'
        include Dradis::Plugins::Echo::Sessionable
      end
      # Force the host to share the Issue's id: the old in-concern sweep keyed on
      # record_id: id, so a same-id host would have wrongly deleted the session.
      host_class.where(id: issue.id).delete_all
      host = host_class.create!(id: issue.id, name: 'echo-sessionable-host')

      expect { host.destroy }.not_to change { described_class.exists?(issue_session.id) }
    end
  end
end
