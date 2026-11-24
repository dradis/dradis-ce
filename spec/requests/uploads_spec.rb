require 'rails_helper'

describe 'upload requests' do

  before do
    login_to_project_as_user

    @uploads_node = @project.plugin_uploads_node
  end

  after { FileUtils.rm_rf(Attachment.pwd.join(@uploads_node.id.to_s)) }

  describe 'POST #parse' do
    let(:uploader) { 'Dradis::Plugins::Projects::Upload::Template' }
    let(:state) { nil }
    let(:send_request) do
      post project_upload_parse_path(@project), params: {
        file: 'temp',
        format: :js,
        state: state,
        uploader: uploader
      }
    end

    it 'creates issues from the uploaded XML' do
      skip 'this is not the right place to test the Upload parser itself'
      expect { send_request }.to change { Issue.count }.by(35)
    end

    context 'small file size (< 1Mb)' do
      let(:importer_class) { "#{uploader}::Importer".constantize }
      let(:importer) { instance_double(importer_class) }
      let(:small_file) { Rails.root.join('tmp/small.file') }

      before do
        File.open(small_file, 'w') { |f| f << '*' }
      end

      after do
        FileUtils.rm(small_file)
      end

      it 'imports the uploaded template' do
        attachments_path = Attachment.pwd.join(@uploads_node.id.to_s)
        attachment_file = attachments_path.join('temp').to_s

        FileUtils.mkdir_p(attachments_path)
        FileUtils.cp(small_file, attachment_file)
        expect(File.exist?(attachment_file)).to be true

        allow(importer_class).to receive(:new).and_return(importer)
        allow(importer).to receive(:import)

        expect(importer_class).to receive(:new).with(
          hash_including(
            default_user_id: @logged_in_as.id,
            state: state
          )
        )
        expect(importer).to receive(:import)

        send_request
      end

      context 'the console' do
        include ActionCable::TestHelper
        include Turbo::Broadcastable::TestHelper

        let(:item_id) { SecureRandom.uuid }

        before do
          attachments_path = Attachment.pwd.join(@uploads_node.id.to_s)
          FileUtils.mkdir_p(attachments_path)
          FileUtils.cp(small_file, attachments_path.join('temp'))

          allow(importer_class).to receive(:new).and_return(importer)
        end

        def final_state
          broadcasts = capture_turbo_stream_broadcasts(ConsoleLogger.stream_name(item_id)) do
            post project_upload_parse_path(@project), params: { file: 'temp', format: :js, item_id: item_id, uploader: uploader }
          end
          broadcasts.last.at_css('[data-state]')['data-state']
        end

        it 'broadcasts the completed state when the file is imported' do
          allow(importer).to receive(:import).and_return(nil)

          expect(final_state).to eq 'completed'
        end

        it 'broadcasts the failed state when the importer rejects the file' do
          allow(importer).to receive(:import).and_return(false)

          expect(final_state).to eq 'failed'
        end
      end
    end

    context 'big file size (> 1Mb)' do
      let(:big_file) { Rails.root.join('tmp/big.file') }

      before do
        File.open(big_file, 'w') do |f|
          f << '*' * (1 + 1024) * 1024
        end
      end
      after do
        FileUtils.rm(big_file)
      end

      it 'enqueues a background job with the right parameters' do
        attachments_path = Attachment.pwd.join(@uploads_node.id.to_s)
        attachment_file = attachments_path.join('temp').to_s

        FileUtils.mkdir_p(attachments_path)
        FileUtils.cp(big_file, attachment_file)
        expect(File.exist?(attachment_file)).to be true

        # Don't want to deal with Redis or Resque here
        FakeJob = Struct.new(:job_id)
        allow(UploadJob).to receive(:perform_later).and_return(FakeJob.new(job_id: 123))

        expect(UploadJob).to receive(:perform_later).with(
          hash_including(
            file: attachment_file,
            plugin_name: uploader,
            state: state
          )
        ).once

        send_request
      end
    end
  end
end
