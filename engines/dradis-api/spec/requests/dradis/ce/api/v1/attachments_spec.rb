require 'rails_helper'

describe "Attachments API" do
  include_context "project scoped API"
  include_context "https"

  let(:node) { create(:node, project: current_project) }

  context "as unauthenticated user" do
    [
      ['get', '/api/nodes/1/attachments/'],
      ['get', '/api/nodes/1/attachments/image.jpg'],
      ['post', '/api/nodes/1/attachments/'],
      ['put', '/api/nodes/1/attachments/image.jpg'],
      ['patch', '/api/nodes/1/attachments/image.jpg'],
      ['delete', '/api/nodes/1/attachments/image.jpg'],
    ].each do |verb, url|
      describe "#{verb.upcase} #{url}" do
        it 'throws 401' do
          send(verb, url, params: {}, env: @env)
          expect(response.status).to eq 401
        end
      end
    end
  end

  context "as authorized user" do
    include_context "authorized API user"

    before(:each) do
      FileUtils.rm_rf Dir[Attachment.pwd.join('*')] until Dir[Attachment.pwd.join('*')].count == 0
    end

    after(:all) do
      FileUtils.rm_rf Dir[Attachment.pwd.join('*')]
    end

    describe "GET /api/nodes/:node_id/attachments" do
      before do
        @attachments = ["image0.png", "image1.png", "image2.png"]
        @attachments.each do |attachment|
          create(:attachment, filename: attachment, node: node)
        end

        # an attachment in another node
        create(:attachment, filename: "image3.png", node: create(:node, project: current_project))

        get "/api/nodes/#{node.id}/attachments", env: @env
      end

      let(:retrieved_attachments) { JSON.parse(response.body) }

      it "responds with HTTP code 200" do
        expect(response.status).to eq(200)
      end

      it "retrieves all the attachments for the given node" do
        expect(retrieved_attachments.count).to eq @attachments.count
        retrieved_filenames = retrieved_attachments.map{ |json| json['filename'] }
        expect(retrieved_filenames).to match_array(@attachments)
      end

      it "returns JSON information about attachments" do
        attachment_0 = retrieved_attachments.detect { |n| n["filename"] == "image0.png" }
        attachment_1 = retrieved_attachments.detect { |n| n["filename"] == "image1.png" }
        attachment_2 = retrieved_attachments.detect { |n| n["filename"] == "image2.png" }

        expect(attachment_0).to eq({
          "filename" => "image0.png",
          "link" => "/projects/#{current_project.id}/nodes/#{node.id}/attachments/image0.png"
        })
        expect(attachment_1).to eq({
          "filename" => "image1.png",
          "link" => "/projects/#{current_project.id}/nodes/#{node.id}/attachments/image1.png"
        })
        expect(attachment_2).to eq({
          "filename" => "image2.png",
          "link" => "/projects/#{current_project.id}/nodes/#{node.id}/attachments/image2.png"
        })
      end

      it "doesn't return attachments from other nodes" do
        expect(retrieved_attachments.map{ |json| json['filename'] }).not_to include "image3.png"
      end
    end

    describe "GET /api/nodes/:node_id/attachments/:filename" do
      before do
        create(:attachment, filename: "image.png", node: node)

        get "/api/nodes/#{node.id}/attachments/image.png", env: @env
      end

      it "responds with HTTP code 200" do
        expect(response.status).to eq 200
      end

      it "responds with HTTP code 404 when not found" do
        get "/api/nodes/#{node.id}/attachments/image_ko.png", env: @env
        expect(response.status).to eq 404
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq "Couldn't find attachment with filename 'image_ko.png'"
      end

      it "returns JSON information about the attachment" do
        retrieved_attachment = JSON.parse(response.body)
        expect(retrieved_attachment.keys).to match_array(%w[filename link])
        expect(retrieved_attachment["filename"]).to eq "image.png"
        expect(retrieved_attachment["link"]).to eq "/projects/#{current_project.id}/nodes/#{node.id}/attachments/image.png"
      end
    end

    describe "POST /api/nodes/:node_id/attachments" do
      let(:post_attachment) {
        file = fixture_file_upload(Rails.root.join('spec/fixtures/files/rails.png'))
        params = { files: [file] }
        url = "/api/nodes/#{node.id}/attachments"

        post url , params: params, env: @env
      }

      it "returns 201 when file saved" do
        post_attachment
        expect(response.status).to eq 201
        expect(File.exist?(Attachment.pwd.join(node.id.to_s, 'rails.png'))).to be true
      end

      it "returns 422 when no file saved" do
        url = "/api/nodes/#{node.id}/attachments"
        post url , params: {}, env: @env

        expect(response.status).to eq 422
        expect(File.exist?(Attachment.pwd.join(node.id.to_s))).to be false
      end

      it "auto-renames the upload if an attachment with the same name already exists" do
        node_attachments = Attachment.pwd.join(node.id.to_s)
        FileUtils.mkdir_p( node_attachments )

        create(:attachment, filename: "rails.png", node: node)
        expect(Dir["#{node_attachments}/*"].count).to eq(1)

        post_attachment

        expect(Dir["#{node_attachments}/*"].count).to eq(2)
      end

      it "returns JSON information about the attachments" do
        file1 = fixture_file_upload(Rails.root.join('spec/fixtures/files/rails.png'))
        file2 = fixture_file_upload(Rails.root.join('spec/fixtures/files/rails.png'))
        params = { files: [file1, file2] }
        url = "/api/nodes/#{node.id}/attachments"

        post url , params: params, env: @env

        retrieved_attachments = JSON.parse(response.body)

        attachment_0 = retrieved_attachments.detect { |n| n["filename"] == "rails.png" }
        attachment_1 = retrieved_attachments.detect { |n| n["filename"] == "rails_copy-01.png" }

        expect(attachment_0.keys).to match_array %w[filename link]
        expect(attachment_0["filename"]).to eq "rails.png"
        expect(attachment_0["link"]).to eq "/projects/#{current_project.id}/nodes/#{node.id}/attachments/rails.png"
        expect(attachment_1.keys).to match_array %w[filename link]
        expect(attachment_1["filename"]).to eq "rails_copy-01.png"
        expect(attachment_1["link"]).to eq "/projects/#{current_project.id}/nodes/#{node.id}/attachments/rails_copy-01.png"
      end
    end

    describe "PUT /api/nodes/:node_id/attachments/:filename" do
      before do
        create(:attachment, filename: "image.png", node: node)
      end

      let(:url) { "/api/nodes/#{node.id}/attachments/image.png" }
      let(:put_attachment) { put url, params: params.to_json, env: @env }

      context "when content_type header = application/json" do
        include_context "content_type: application/json"

        context "with params for a valid attachment" do
          let(:params) { { attachment: { filename: "image_renamed.png" } } }

          it "responds with HTTP code 200 if attachment exists" do
            put_attachment
            expect(response.status).to eq 200
          end

          it "responds with HTTP code 404 if attachemnt doesn't exist" do
            bad_url = "/api/nodes/#{node.id}/attachments/image_ko.png"
            put bad_url, params: params, env: @env
            expect(response.status).to eq(400)
          end

          it "updates the attachment" do
            put_attachment

            expect(File.exist?(Attachment.pwd.join(node.id.to_s, 'image.png'))).to be false
            expect(File.exist?(Attachment.pwd.join(node.id.to_s, 'image_renamed.png'))).to be true
          end

          it "returns the attributes of the updated attachment as JSON" do
            put_attachment
            retrieved_attachment = JSON.parse(response.body)
            expect(retrieved_attachment["filename"]).to eq "image_renamed.png"
          end

          it "responds with HTTP code 422 if attachment already exists" do
            create(:attachment, filename: "image_renamed.png", node: node)
            put_attachment
            expect(response.status).to eq(422)
            retrieved_attachment = JSON.parse(response.body)
            expect(retrieved_attachment["filename"]).to eq "image.png"
          end
        end

        context "with params for an invalid attachment" do
          let(:params) { { attachment: { filename: "a"*65536 } } } # too long

          it "responds with HTTP code 422" do
            put_attachment
            expect(response.status).to eq 422
          end

          it "doesn't update the attachment" do
            put_attachment
            expect(File.exist?(Attachment.pwd.join(node.id.to_s, 'image.png'))).to be true
            expect(File.exist?(Attachment.pwd.join(node.id.to_s, 'image_renamed.png'))).to be false
          end
        end

        context "when no :attachment param is sent" do
          let(:params) { {} }

          it "doesn't update the attachment" do
            put_attachment
            expect(File.exist?(Attachment.pwd.join(node.id.to_s, 'image.png'))).to be true
          end

          it "responds with HTTP code 422" do
            put_attachment
            expect(response.status).to eq 422
          end
        end

        context "when invalid JSON is sent" do
          it "responds with HTTP code 400" do
            json_payload = '{"attachment":{"filename":"A malformed label", , }}'
            put url, params: json_payload, env: @env
            expect(response.status).to eq(400)
          end
        end
      end

      context "when JSON is not sent" do
        let(:params) { { attachment: { filename: "image_renamed.jpg" } } }

        it "responds with HTTP code 415" do
          put url, params: params, env: @env
          expect(File.exist?(Attachment.pwd.join(node.id.to_s, 'image.png'))).to be true
          expect(response.status).to eq 415
        end
      end
    end

    describe "DELETE /api/nodes/:node_id/attachments/:filename" do
      let(:attachment) { "image.png" }

      let(:delete_attachment) do
        create(:attachment, filename: attachment, node: node)
        delete "/api/nodes/#{node.id}/attachments/#{attachment}", env: @env
      end

      it "deletes the attachment" do
        delete_attachment
        expect(File.exist?(Attachment.pwd.join(node.id.to_s, attachment))).to\
         be false
      end

      it "responds with error code 200" do
        delete_attachment
        expect(response.status).to eq(200)
      end

      it "returns JSON with a success message" do
        delete_attachment
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["message"]).to eq\
          "Resource deleted successfully"
      end
    end
  end
end
