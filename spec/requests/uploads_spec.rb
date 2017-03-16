require 'rails_helper'

describe "upload requests" do

  before do
    # login as admin
    Configuration.create(name: 'admin:password', value: ::BCrypt::Password.create('rspec_pass'))
    @user = create(:user, :admin)
    post session_path, params: { login: @user.email, password: 'rspec_pass' }

    @uploads_node = Node.plugin_uploads_node
  end

  after { FileUtils.rm_rf(Attachment.pwd.join(@uploads_node.id.to_s)) }

  describe "POST #parse" do
    let(:uploader) { 'Dradis::Plugins::Projects::Upload::Template' }
    let(:send_request) do
      post upload_parse_path, params: { file: "temp", format: :js, uploader: uploader }
    end

    it "creates issues from the uploaded XML" do
      skip 'this is not the right place to test the Upload parser itself'
      expect{send_request}.to change{Issue.count}.by(35)
    end

    context "small file size (< 1Mb)" do
      pending
    end

    context "big file size (> 1Mb)" do
      let(:big_file) { Rails.root.join('tmp/big.file') }

      before do
        File.open(big_file, 'w') do |f|
          f << "*" * (1+1024)*1024
        end
      end
      after do
        FileUtils.rm(big_file)
      end

      it "enqueues a background job with the right parameters" do
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
            plugin_name: uploader
          )
        ).once

        send_request
      end
    end
  end
end
