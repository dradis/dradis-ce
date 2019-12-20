require 'rails_helper'

describe "Evidence API" do

  include_context "project scoped API"
  include_context "https"

  let(:node)  { create(:node, project: current_project) }
  let(:issue) { create(:issue, node: current_project.issue_library) }

  context "as unauthenticated user" do
    [
      ['get', '/api/nodes/1/evidence/'],
      ['get', '/api/nodes/1/evidence/1'],
      ['post', '/api/nodes/1/evidence/'],
      ['put', '/api/nodes/1/evidence/1'],
      ['patch', '/api/nodes/1/evidence/1'],
      ['delete', '/api/nodes/1/evidence/1'],
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

    let(:category) { create(:category) }

    describe "GET /api/nodes/:node_id/evidence" do
      before do
        @issues = create_list(:issue, 3, node: current_project.issue_library)
        @evidence = [
          Evidence.create!(node: node, content: "#[a]#\nA", issue: @issues[0]),
          Evidence.create!(node: node, content: "#[b]#\nB", issue: @issues[1]),
          Evidence.create!(node: node, content: "#[c]#\nC", issue: @issues[2]),
        ]
        @other_evidence = create(:evidence, issue: issue, node: current_project.issue_library)
        get "/api/nodes/#{node.id}/evidence", env: @env
      end

      let(:retrieved_evidence) { JSON.parse(response.body) }

      it "responds with HTTP code 200" do
        expect(response.status).to eq(200)
      end

      it "retrieves all the evidence for the given node" do
        expect(retrieved_evidence.count).to eq 3
        issue_titles = retrieved_evidence.map{ |json| json['issue']['title'] }
        expect(issue_titles).to match_array @issues.map(&:title)
      end

      it "returns JSON data about the evidence's fields and issue" do
        ev_0 = retrieved_evidence.find { |n| n["issue"]["id"] == @issues[0].id }
        ev_1 = retrieved_evidence.find { |n| n["issue"]["id"] == @issues[1].id }
        ev_2 = retrieved_evidence.find { |n| n["issue"]["id"] == @issues[2].id }

        expect(ev_0["fields"].keys).to \
          match_array (@evidence[0].local_fields.keys << "a")
        expect(ev_0["fields"]["a"]).to eq "A"
        expect(ev_0["issue"]["title"]).to eq @issues[0].title
        expect(ev_1["fields"].keys).to \
          match_array (@evidence[2].local_fields.keys << "b")
        expect(ev_1["fields"]["b"]).to eq "B"
        expect(ev_1["issue"]["title"]).to eq @issues[1].title
        expect(ev_2["fields"].keys).to \
          match_array (@evidence[2].local_fields.keys << "c")
        expect(ev_2["fields"]["c"]).to eq "C"
        expect(ev_2["issue"]["title"]).to eq @issues[2].title
      end

      it "doesn't return evidence from other nodes" do
        retrieved_ids = retrieved_evidence.map { |n| n["id"] }
        expect(retrieved_ids).not_to include @other_evidence.id
      end
    end

    describe "GET /api/nodes/:node_id/evidence/:id" do
      before do
        @issue    = create(:issue, node: current_project.issue_library)
        @evidence = node.evidence.create!(
          content: "#[foo]#\nbar\n#[fizz]#\nbuzz",
          issue:   @issue,
        )
        get "/api/nodes/#{node.id}/evidence/#{@evidence.id}", env: @env
      end

      it "responds with HTTP code 200" do
        expect(response.status).to eq 200
      end

      it "returns JSON information about the evidence" do
        retrieved_evidence = JSON.parse(response.body)
        expect(retrieved_evidence["id"]).to eq @evidence.id
        expect(retrieved_evidence["fields"].keys).to match_array(
          @evidence.local_fields.keys + %w(fizz foo)
        )
        expect(retrieved_evidence["fields"]["foo"]).to eq "bar"
        expect(retrieved_evidence["fields"]["fizz"]).to eq "buzz"
        expect(retrieved_evidence["issue"]["id"]).to eq @issue.id
        expect(retrieved_evidence["issue"]["title"]).to eq @issue.title
      end
    end

    describe "POST /api/nodes/:node_id/evidence" do
      let(:url) { "/api/nodes/#{node.id}/evidence" }
      let(:issue) { create(:issue, node: current_project.issue_library) }
      let(:post_evidence) { post url, params: params.to_json, env: @env }

      context "when content_type header = application/json" do
        include_context "content_type: application/json"

        context "with params for a valid evidence" do
          let(:params) { { evidence: { content: "New evidence", issue_id: issue.id } } }

          it "responds with HTTP code 201" do
            post_evidence
            expect(response.status).to eq 201
          end

          it "creates an evidence" do
            expect{post_evidence}.to change{node.evidence.count}
            new_evidence = node.evidence.last
            expect(new_evidence.content).to eq "New evidence"
            expect(new_evidence.issue).to eq issue
          end

          let(:submit_form) { post_evidence }
          include_examples 'creates an Activity', :create, Evidence
          include_examples 'sets the whodunnit', :create, Evidence
        end

        context "with params for an invalid evidence" do
          let(:params) { { evidence: { content: "New evidence" } } } # no issue

          it "responds with HTTP code 422" do
            post_evidence
            expect(response.status).to eq 422
          end

          it "doesn't create an evidence" do
            expect{post_evidence}.not_to change{Evidence.count}
          end
        end

        context "when no :evidence param is sent" do
          let(:params) { {} }

          it "doesn't create an evidence" do
            expect{post_evidence}.not_to change{Evidence.count}
          end

          it "responds with HTTP code 422" do
            post_evidence
            expect(response.status).to eq(422)
          end
        end

        context "when invalid JSON is sent" do
          it "responds with HTTP code 400" do
            json_payload = '{"evidence":{"label":"A malformed label", , }}'
            post url, params: json_payload, env: @env
            expect(response.status).to eq(400)
          end
        end
      end

      context "when JSON is not sent" do
        it "responds with HTTP code 415" do
          params = { evidence: { } }
          post url, params: params, env: @env
          expect(response.status).to eq(415)
        end
      end
    end

    describe "PUT /api/nodes/:node_id/evidence/:id" do
      let(:evidence) do
        create(:evidence, node: node, content: "My content", issue: issue)
      end

      let(:url) { "/api/nodes/#{node.id}/evidence/#{evidence.id}" }
      let(:put_evidence) { put url, params: params.to_json, env: @env }

      context "when content_type header = application/json" do
        include_context "content_type: application/json"

        context "with params for a valid evidence" do
          let(:params) { { evidence: { content: "New content" } } }

          it "responds with HTTP code 200" do
            put_evidence
            expect(response.status).to eq 200
          end

          it "updates the evidence" do
            put_evidence
            expect(evidence.reload.content).to eq "New content"
          end

          it "returns the attributes of the updated evidence as JSON" do
            put_evidence
            retrieved_evidence = JSON.parse(response.body)
            expect(retrieved_evidence["content"]).to eq "New content"
          end

          let(:submit_form) { put_evidence }
          let(:model) { evidence }
          include_examples 'creates an Activity', :update
          include_examples 'sets the whodunnit', :update
        end

        context "with params for an invalid evidence" do
          let(:params) { { evidence: { content: "a"*65536 } } } # too long

          it "responds with HTTP code 422" do
            put_evidence
            expect(response.status).to eq 422
          end

          it "doesn't update the evidence" do
            expect{put_evidence}.not_to change{evidence.reload.attributes}
          end
        end

        context "when no :evidence param is sent" do
          let(:params) { {} }

          it "doesn't update the evidence" do
            expect{put_evidence}.not_to change{evidence.reload.attributes}
          end

          it "responds with HTTP code 422" do
            put_evidence
            expect(response.status).to eq 422
          end
        end

        context "when invalid JSON is sent" do
          it "responds with HTTP code 400" do
            json_payload = '{"evidence":{"label":"A malformed label", , }}'
            put url, params: json_payload, env: @env
            expect(response.status).to eq(400)
          end
        end
      end

      context "when JSON is not sent" do
        let(:params) { { evidence: { content: "New Evidence" } } }

        it "responds with HTTP code 415" do
          expect{put url, params: params, env: @env}.not_to change{evidence.reload.attributes}
          expect(response.status).to eq 415
        end
      end
    end

    describe "DELETE /api/nodes/:node_id/evidence/:id" do
      let(:evidence) { create(:evidence, node: node, content: "My Evidence", issue: issue) }

      let(:delete_evidence) do
        delete "/api/nodes/#{node.id}/evidence/#{evidence.id}", env: @env
      end

      it "deletes the evidence" do
        evidence_id = evidence.id
        delete_evidence
        expect(Evidence.find_by_id(evidence_id)).to be_nil
      end

      it "responds with error code 200" do
        delete_evidence
        expect(response.status).to eq(200)
      end

      it "returns JSON with a success message" do
        delete_evidence
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["message"]).to eq\
          "Resource deleted successfully"
      end

      let(:submit_form) { delete_evidence }
      let(:model) { evidence }
      include_examples "creates an Activity", :destroy
    end
  end
end
