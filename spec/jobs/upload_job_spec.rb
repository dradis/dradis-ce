require 'rails_helper'

describe UploadJob do
  let(:importer_class) { Dradis::Plugins::Projects::Upload::Template::Importer }
  let(:importer) { instance_double(importer_class) }
  let(:project) { create(:project) }
  let(:tracker) { instance_double(JobTracker, update_state: nil, state: {}) }
  let(:uid) { SecureRandom.uuid }

  before do
    allow(importer_class).to receive(:new).and_return(importer)
    allow(JobTracker).to receive(:new).and_return(tracker)
  end

  def perform
    described_class.perform_now(
      default_user_id: create(:user).id,
      file: 'file.xml',
      plugin_name: 'Dradis::Plugins::Projects::Upload::Template',
      project_id: project.id,
      state: 'draft',
      uid: uid
    )
  end

  it 'writes the completed line when the importer returns anything but false' do
    allow(importer).to receive(:import).and_return(nil)

    perform

    expect(Log.where(uid: uid).last.text).to eq Log::COMPLETED
  end

  context 'when the importer rejects the file' do
    before { allow(importer).to receive(:import).and_return(false) }

    it 'writes the failed line' do
      perform

      expect(Log.where(uid: uid).last.text).to eq Log::FAILED
    end

    it 'reports the job as failed, not completed' do
      allow(tracker).to receive(:state).and_return({ state: 'failed' })

      perform

      expect(tracker).to have_received(:update_state).with(hash_including(state: :failed))
      expect(tracker).to_not have_received(:update_state).with(state: :completed)
    end
  end

  it 'writes the failed line when the import raises, even if the tracker is unavailable' do
    allow(importer).to receive(:import).and_raise('Boom')
    allow(tracker).to receive(:update_state).with(hash_including(state: :failed)).and_raise(Redis::CannotConnectError)

    expect { perform }.to raise_error(Redis::CannotConnectError)

    expect(Log.where(uid: uid).last.text).to eq Log::FAILED
  end
end
