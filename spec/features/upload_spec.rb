require "spec_helper"

describe "Upload Manager" do
  describe "uploading a file" do
    before do
      login_to_project_as_user
      @node = Node.find_or_create_by(label: ::Configuration.plugin_uploads_node, project: @project)
    end

    after do
      FileUtils.rm_rf(Attachment.pwd.join(@node.id.to_s))
    end

    context "small file size (< 1Mb)" do
      pending
    end

    context "big file size (> 1<Mb)" do
      let(:big_file) { Rails.root.join('tmp/big.file') }

      before do
        puts "exist? #{File.exist?(big_file)}"
        File.open(big_file, 'w') do |f|
          f << "*" * 1024*1024
        end
        puts "exist? #{File.exist?(big_file)}"
      end
      after do
        puts "exist? #{File.exist?(big_file)}"
        FileUtils.rm(big_file)
        puts "exist? #{File.exist?(big_file)}"
      end

      it "enqueues a background job with the right parameters", js: true do
        visit upload_manager_path
        uploader = first('select option').text
        select uploader, from: 'uploader'
        attach_file('file', big_file.to_s)

        # Start is triggered via JS on file select
        # see ./spec/wait_for_ajax
        wait_for_ajax 

        # Don't want to deal with Redis or Resque here
        allow(UploadProcessor).to receive(:create).and_return(123)

        # But make sure we're enqueuing it
        attachment_path = Attachment.pwd.join(
          @node.id.to_s,
          big_file.basename.to_s
        ).to_s
        expect(UploadProcessor).to receive(:create).with(
          hash_including(
            file: attachment_path,
            plugin: uploader,
            project_id: @project.id
          )
        ).once
      end
    end
  end
end
