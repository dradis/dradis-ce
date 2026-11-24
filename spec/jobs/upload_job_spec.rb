require 'rails_helper'

describe UploadJob do
  include ActionCable::TestHelper
  include Turbo::Broadcastable::TestHelper

  let(:importer_class) { Dradis::Plugins::Projects::Upload::Template::Importer }
  let(:importer) { instance_double(importer_class) }
  let(:project) { create(:project) }
  let(:tracker) { instance_double(JobTracker, update_state: nil, state: {}) }
  let(:uid) { SecureRandom.uuid }

  before do
    allow(importer_class).to receive(:new).and_return(importer)
    allow(JobTracker).to receive(:new).and_return(tracker)
  end

  def final_state(&block)
    broadcasts = capture_turbo_stream_broadcasts(ConsoleLogger.stream_name(uid), &block)
    broadcasts.last.at_css('[data-state]')['data-state']
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

  it 'broadcasts the completed state when the importer returns anything but false' do
    allow(importer).to receive(:import).and_return(nil)

    expect(final_state { perform }).to eq 'completed'
  end

  it 'broadcasts the failed state when the importer rejects the file' do
    allow(importer).to receive(:import).and_return(false)

    expect(final_state { perform }).to eq 'failed'
  end

  it 'broadcasts the failed state when the import raises' do
    allow(importer).to receive(:import).and_raise('Boom')

    expect(final_state { perform }).to eq 'failed'
  end
end
