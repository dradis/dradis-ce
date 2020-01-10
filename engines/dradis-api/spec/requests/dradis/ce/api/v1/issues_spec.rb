require 'rails_helper'

describe "Issues API" do

  include_context "project scoped API"
  include_context "https"

  context "as unauthenticated user" do
    [
      ['get', '/api/issues/'],
      ['get', '/api/issues/1'],
      ['post', '/api/issues/'],
      ['put', '/api/issues/1'],
      ['patch', '/api/issues/1'],
      ['delete', '/api/issues/1'],
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

    describe "GET /api/issues" do
      before(:each) do
        @issues = create_list(:issue, 10, node: current_project.issue_library).sort_by(&:title)

        get "/api/issues", env: @env
        expect(response.status).to eq(200)

        @retrieved_issues = JSON.parse(response.body)
      end

      it "retrieves all the issues" do
        titles = @issues.map(&:title)
        retrieved_titles = @retrieved_issues.map{ |json| json['title'] }

        expect(@retrieved_issues.count).to eq(@issues.count)
        expect(retrieved_titles).to match_array(titles)
      end

      it "includes fields" do
        @retrieved_issues.each do |issue|
          expect(issue).to have_key('id')
          db_issue = Issue.find(issue['id'])

          expect(issue['fields']).not_to be_empty
          expect(issue['fields'].count).to eq(db_issue.fields.count)
          expect(issue['fields'].keys).to eq(db_issue.fields.keys)
        end
      end
    end

    describe "GET /api/issue/:id" do
      before(:each) do
        @issue = create(:issue, node: current_project.issue_library, text: "#[a]#\nb\n\n#[c]#\nd\n\n#[e]#\nf\n\n")

        get "/api/issues/#{ @issue.id }", env: @env
        expect(response.status).to eq(200)

        @retrieved_issue = JSON.parse(response.body)
      end

      it "retrieves a specific issue" do
        expect(@retrieved_issue['id']).to eq @issue.id
      end

      it "includes fields" do
        expect(@retrieved_issue['fields']).not_to be_empty
        expect(@retrieved_issue['fields'].keys).to eq @issue.fields.keys
        expect(@retrieved_issue['fields'].count).to eq @issue.fields.count
      end
    end

    describe "POST /api/issues" do
      let(:valid_params) { { issue: { text: "#[Title]#\nRspec issue\n\n#[c]#\nd\n\n#[e]#\nf\n\n" } } }
      let(:valid_post) do
        post "/api/issues", params: valid_params.to_json, env: @env.merge("CONTENT_TYPE" => 'application/json')
      end

      it "creates a new issue" do
        expect{valid_post}.to change{ current_project.issues.count }.by(1)
        expect(response.status).to eq(201)
        retrieved_issue = JSON.parse(response.body)
        expect(retrieved_issue['text']).to eq valid_params[:issue][:text]
      end

      it "tags the issue from the Tags field" do
        tag_name = '!2ca02c_info'
        valid_params[:issue][:text] << "#[Tags]#\n\n#{tag_name}\n\n"

        expect { valid_post }.to change{ current_project.issues.count }.by(1)
        expect(response.status).to eq(201)

        retrieved_issue = JSON.parse(response.body)
        database_issue  = current_project.issues.find(retrieved_issue['id'])

        expect(database_issue.tag_list).to eq(tag_name)
      end

      let(:submit_form) { valid_post }
      include_examples 'creates an Activity', :create, Issue
      include_examples 'sets the whodunnit', :create, Issue

      it "throws 415 unless JSON is sent" do
        params = { issue: { name: "Bad Issue" } }
        post "/api/issues", params: params, env: @env
        expect(response.status).to eq(415)
      end

      it "throws 422 if issue is invalid" do
        params = { issue: { text: "A"*(65535+1) } }
        expect {
          post "/api/issues", params: params.to_json, env: @env.merge("CONTENT_TYPE" => 'application/json')
        }.not_to change { current_project.issues.count }
        expect(response.status).to eq(422)
      end
    end

    describe "PUT /api/issues/:id" do
      let(:issue) { create(:issue, node: current_project.issue_library, text: "Existing Issue") }
      let(:valid_params) { { issue: { text: "Updated Issue" } } }
      let(:valid_put) do
        put "/api/issues/#{issue.id}", params: valid_params.to_json, env: @env.merge("CONTENT_TYPE" => 'application/json')
      end

      it "updates a issue" do
        valid_put
        expect(response.status).to eq(200)

        expect(current_project.issues.find(issue.id).text).to eq valid_params[:issue][:text]

        retrieved_issue = JSON.parse(response.body)
        expect(retrieved_issue['text']).to eq valid_params[:issue][:text]
      end

      let(:submit_form) { valid_put }
      let(:model) { issue }
      include_examples 'creates an Activity', :update
      include_examples 'sets the whodunnit', :update

      it "throws 415 unless JSON is sent" do
        params = { issue: { text: "Bad issuet" } }
        put "/api/issues/#{ issue.id }", params: params, env: @env
        expect(response.status).to eq(415)
      end

      it "throws 422 if issue is invalid" do
        params = { issue: { text: "B"*(65535+1) } }
        put "/api/issues/#{ issue.id }", params: params.to_json, env: @env.merge("CONTENT_TYPE" => 'application/json')
        expect(response.status).to eq(422)
      end
    end

    describe "DELETE /api/issue/:id" do
      let(:issue) { create(:issue, node: current_project.issue_library) }

      let(:delete_issue) { delete "/api/issues/#{ issue.id }", env: @env }

      it "deletes a issue" do
        delete_issue
        expect(response.status).to eq(200)
        expect { current_project.issues.find(issue.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      let(:submit_form) { delete_issue }
      let(:model) { issue }
      include_examples "creates an Activity", :destroy
    end
  end
end
