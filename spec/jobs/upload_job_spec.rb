require 'rails_helper'

describe UploadJob do
  describe '#perform' do
    let(:importer) { instance_double(importer_class) }
    let(:importer_class) { "#{plugin_name}::Importer".constantize }
    let(:plugin_name) { 'Dradis::Plugins::Projects::Upload::Template' }

    let(:perform) do
      described_class.new.perform(
        default_user_id: create(:user).id,
        file: 'temp',
        plugin_name: plugin_name,
        project_id: 1,
        state: 'draft',
        uid: 1
      )
    end

    before do
      allow(importer_class).to receive(:new).and_return(importer)
    end

    it 'logs completion when the importer succeeds' do
      allow(importer).to receive(:import).and_return(true)

      perform

      expect(Log.last.text).to eq('Worker process completed.')
    end

    it 'logs failure when the importer rejects the file' do
      allow(importer).to receive(:import).and_return(false)

      perform

      expect(Log.last.text).to eq('Worker process failed.')
    end
  end
end
