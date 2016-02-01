require "spec_helper"

describe "upload requests" do

  before do
    # login as admin
    @user = create(:user, :admin)
    post session_path, login: @user.email, password: @user.password
    @project = create(:project)
    @project.authors << @user
    get use_project_path(@project)

    @uploads_node = Node.create!(
      label: ::Configuration.plugin_uploads_node,
      project_id: session[:project_id]
    )
    @attachment = Attachment.new("temp", node_id: @uploads_node.id )
    @attachment << File.read(
      Rails.root.join("spec/support/sample_files/nessus/example_v2.nessus")
    )
    @attachment.save
  end

  after { FileUtils.rm_rf(Attachment.pwd.join(@uploads_node.id.to_s)) }

  describe "POST #parse" do
    let(:uploader) { 'Dradis::Plugins::Nessus' }
    let(:send_request) do
      post upload_parse_path, file: "temp", format: :js, uploader: uploader
    end

    it "creates issues from the uploaded XML" do
      expect{send_request}.to change{Issue.count}.by(35)
    end

    it "filters findings through the rules engine" do
      rule = Dradis::Pro::Rules::Rules::AndRule.active.create!(name: "Test rule")
      Dradis::Pro::Rules::Conditions::FieldCondition.create!(
        properties: {
          field: "Title",
          operator: "==",
          plugin: :nessus,
          value: "Broken Web Servers"
        },
        rule: rule
      )
      Dradis::Pro::Rules::Actions::ChangeValueAction.create!(
        properties: { field: "Title", new_value: "Damaged Net Waiters" },
        rule: rule
      )

      expect{send_request}.to change{Issue.count}.by(35)

      expect(
        Issue.all.select { |i| i.text =~ /Damaged Net Waiters/ }.size
      ).to eq 1
    end

    context "small file size (< 1Mb)" do
      pending
    end

    context "big file size (> 1<Mb)", focus: true do
      let(:big_file) { Rails.root.join('tmp/big.file') }

      before do
        File.open(big_file, 'w') do |f|
          f << "*" * 1024*1024
        end
      end
      after do
        FileUtils.rm(big_file)
      end

      it "enqueues a background job with the right parameters" do

        attachment_path = Attachment.pwd.join(@uploads_node.id.to_s, 'temp').to_s

        FileUtils.cp(big_file, attachment_path)

        # Don't want to deal with Redis or Resque here
        allow(UploadProcessor).to receive(:create).and_return(123)

        expect(UploadProcessor).to receive(:create).with(
          hash_including(
            file: attachment_path,
            plugin: uploader,
            project_id: @project.id
          )
        ).once

        send_request
      end
    end
  end
end
