require 'rails_helper'

describe "Nodes API" do

  include_context "project scoped API"
  include_context "https"

  context "as unauthenticated user" do
    [
      ['get', '/api/nodes/'],
      ['get', '/api/nodes/1'],
      ['post', '/api/nodes/'],
      ['put', '/api/nodes/1'],
      ['patch', '/api/nodes/1'],
      ['delete', '/api/nodes/1'],
    ].each do |verb, url|
      describe "#{verb.upcase} #{url}" do
        it 'throws 401' do
          send(verb, url, params: {}, env: @env)
          expect(response.status).to eq 401
        end
      end
    end
  end

  context "as authauthorized user" do
    include_context "authorized API user"

    describe "GET /api/nodes" do
      it "retrieves all the nodes" do
        nodes = create_list(:node, 10, project: current_project).sort_by(&:updated_at)
        node_labels = nodes.map(&:label)

        get "/api/nodes", env: @env

        expect(response.status).to eq(200)

        retrieved_nodes       = JSON.parse(response.body)
        retrieved_node_labels = retrieved_nodes.map{ |p| p['label'] }

        expect(retrieved_nodes.count).to eq(nodes.count)
        expect(retrieved_node_labels).to match_array(node_labels)
      end
    end

    describe "GET /api/nodes/:id" do
      it "retrieves a specific node" do
        node = create(:node, label: "Existing Node", project: current_project)

        get "/api/nodes/#{ node.id }", env: @env
        expect(response.status).to eq(200)

        retrieved_node = JSON.parse(response.body)
        expect(retrieved_node['label']).to eq node.label
      end
    end

    describe "POST /api/nodes" do
      let!(:parent_node_id) { Project.new.plugin_parent_node.id }
      let(:valid_post) do
        post "/api/nodes", params: valid_params.to_json, env: @env.merge("CONTENT_TYPE" => 'application/json')
      end
      let(:valid_params) do
        {
          node: {
            label:     "New Node",
            type_id:   Node::Types::HOST,
            parent_id: parent_node_id,
            position:  3
          }
        }
      end

      it "creates a new node" do
        expect{valid_post}.to change{Node.count}.by(1)
        expect(response.status).to eq(201)

        retrieved_node = JSON.parse(response.body)

        expect(response.location).to eq(dradis_api.node_url(retrieved_node['id']))

        valid_params[:node].each do |attr, value|
          expect(retrieved_node[attr.to_s]).to eq value
        end
      end

      # Activity shared example was originally written for feature requests and
      # expects a 'submit_form' let variable to be defined:
      let(:submit_form) { valid_post }
      include_examples "creates an Activity", :create, Node

      it "throws 415 unless JSON is sent" do
        params = { node: { } }
        post "/api/nodes", params: params, env: @env
        expect(response.status).to eq(415)
      end

      it "throws 422 if node is invalid" do
        params = { node: { label: "" } }
        post "/api/nodes", params: params.to_json, env: @env.merge("CONTENT_TYPE" => 'application/json')
        expect(response.status).to eq(422)
      end

      it "throws 422 if no :node param is sent" do
        params = { }
        post "/api/nodes", params: params.to_json, env: @env.merge("CONTENT_TYPE" => 'application/json')
        expect(response.status).to eq(422)
      end

      it "throws 400 if invalid JSON is sent" do
        invalid_tokens = ', , '
        json_payload = %Q|{"node":{"label":"A malformed label"#{ invalid_tokens }}}|
        post "/api/nodes", params: json_payload, env: @env.merge("CONTENT_TYPE" => 'application/json')
        expect(response.status).to eq(400)
      end
    end

    describe "PUT /api/nodes/:id" do

      let(:node) { create(:node, label: "Existing Node", project: current_project) }

      let(:valid_put) do
        put "/api/nodes/#{ node.id }", params: valid_params.to_json, env: @env.merge("CONTENT_TYPE" => 'application/json')
      end
      let(:valid_params) { { node: { label: "Updated Node" } } }

      it "updates a node" do
        valid_put
        expect(response.status).to eq(200)
        expect(current_project.nodes.find(node.id).label).to eq valid_params[:node][:label]
        retrieved_node = JSON.parse(response.body)
        expect(retrieved_node['label']).to eq valid_params[:node][:label]
      end

      let(:submit_form) { valid_put }
      let(:model) { node }
      include_examples "creates an Activity", :update

      it "assigns :type_id" do
        params = { node: { type_id: Node::Types::HOST } }
        put "/api/nodes/#{ node.id }", params: params.to_json, env: @env.merge("CONTENT_TYPE" => 'application/json')
        expect(response.status).to eq(200)
        expect(current_project.nodes.find(node.id).type_id).to eq(Node::Types::HOST)
      end

      it "throws 415 unless JSON is sent" do
        params = { node: { label: "Bad Node" } }
        put "/api/nodes/#{ node.id }", params: params, env: @env
        expect(response.status).to eq(415)
      end

      it "throws 422 if node is invalid" do
        params = { node: { label: "" } }
        put "/api/nodes/#{ node.id }", params: params.to_json, env: @env.merge("CONTENT_TYPE" => 'application/json')
        expect(response.status).to eq(422)
      end

      it "throws 422 if no :node param is sent" do
        params = { }
        put "/api/nodes/#{ node.id }", params: params.to_json, env: @env.merge("CONTENT_TYPE" => 'application/json')
        expect(response.status).to eq(422)
      end

      it "throws 400 if invalid JSON is sent" do
        invalid_tokens = ', , '
        json_payload = %Q|{"node":{"label":"A malformed label"#{ invalid_tokens }}}|
        put "/api/nodes/#{ node.id }", params: json_payload, env: @env.merge("CONTENT_TYPE" => 'application/json')
        expect(response.status).to eq(400)
      end

    end

    describe "DELETE /api/nodes/:id" do

      let(:node) { create(:node, label: "Existing Node", project: current_project) }
      let(:delete_node) { delete "/api/nodes/#{ node.id }", env: @env }

      it "deletes a node" do
        delete_node
        expect(response.status).to eq(200)

        expect { current_project.nodes.find(node.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      let(:model) { node }
      let(:submit_form) { delete_node }
      include_examples "creates an Activity", :destroy
    end
  end

end
