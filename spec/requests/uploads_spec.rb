require 'rails_helper'

describe 'upload requests' do

  before do
    login_to_project_as_user

    @uploads_node = @project.plugin_uploads_node
  end

  after { FileUtils.rm_rf(Attachment.pwd.join(@uploads_node.id.to_s)) }

  describe 'POST #create' do
    let(:file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'rails.png'), 'image/png') }
    let(:uploader) { 'Dradis::Plugins::Projects::Upload::Template' }
    let(:state) { Issue.states.keys.first }

    it 'returns JSON with item_id and attachment when requested' do
      post project_upload_manager_path(@project),
           params: { file: file, uploader: uploader, state: state },
           headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')

      json = response.parsed_body
      expect(json['item_id']).to be_a(String)
      expect(json['attachment']).to be_a(String)
    end

    it 'still renders the JS response for legacy requests' do
      post project_upload_manager_path(@project),
           params: { file: file, uploader: uploader, state: state, format: :js }

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/javascript')
    end
  end

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
        attachment_file  = attachments_path.join('temp').to_s

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
        attachment_file  = attachments_path.join('temp').to_s

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
