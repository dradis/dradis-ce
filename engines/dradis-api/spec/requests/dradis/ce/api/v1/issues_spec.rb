require 'spec_helper'

describe "Issues API" do

  before(:each) do
    @env = { "HTTPS" => "on" }
  end

  context "as unauthenticated user" do
    describe "GET /api/issues" do
      it "throws 401" do
        get "/api/issues", {}, @env
        expect(response.status).to eq(401)
      end
    end
    describe "GET /api/issues/:id" do
      it "throws 401" do
        get "/api/issues/1", {}, @env
        expect(response.status).to eq(401)
      end
    end
    describe "POST /api/issues" do
      it "throws 401" do
        post "/api/issues", {}, @env
        expect(response.status).to eq(401)
      end
    end
    describe "PUT /api/issues/:id" do
      it "throws 401" do
        put "/api/issues/1", {}, @env
        expect(response.status).to eq(401)
      end
    end
    describe "DELETE /api/issues/:id" do
      it "throws 401" do
        delete "/api/issues/1", {}, @env
        expect(response.status).to eq(401)
      end
    end
  end

  context "as authenticated user" do
    before do
      allow(Configuration).to receive(:shared_password).and_return(::BCrypt::Password.create('rspec_pass'))
    end
    
    before(:each) do
      @env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials('rspec', 'rspec_pass')
    end

    describe "GET /api/issues" do
      before(:each) do
        @issues = create_list(:issue, 10).sort_by(&:title)

        get "/api/issues", {}, @env
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
        @issue = create(:issue, text: "#[a]#\nb\n\n#[c]#\nd\n\n#[e]#\nf\n\n")

        get "/api/issues/#{ @issue.id }", {}, @env
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
      it "creates a new issue" do
        params = { issue: { text: "#[Title]#\nRspec issue\n\n#[c]#\nd\n\n#[e]#\nf\n\n" } }
        expect {
          post "/api/issues", params.to_json, @env.merge("CONTENT_TYPE" => 'application/json')
        }.to change { Issue.count }.by(1)
        expect(response.status).to eq(201)

        retrieved_issue = JSON.parse(response.body)
        expect(retrieved_issue['text']).to eq params[:issue][:text]
      end

      it "throws 415 unless JSON is sent" do
        params = { issue: { name: "Bad Issue" } }
        post "/api/issues", params, @env
        expect(response.status).to eq(415)
      end

      it "throws 422 if issue is invalid" do
        params = { issue: { text: "A"*(65535+1) } }
        expect {
          post "/api/issues", params.to_json, @env.merge("CONTENT_TYPE" => 'application/json')
        }.not_to change { Issue.count }
        expect(response.status).to eq(422)
      end
    end

    describe "PUT /api/issues/:id" do

      let(:issue) { create(:issue, text: "Existing Issue") }

      it "updates a issue" do
        params = { issue: { text: "Updated Issue" } }

        put "/api/issues/#{ issue.id }", params.to_json, @env.merge("CONTENT_TYPE" => 'application/json')
        expect(response.status).to eq(200)

        expect(Issue.find(issue.id).text).to eq params[:issue][:text]

        retrieved_issue = JSON.parse(response.body)
        expect(retrieved_issue['text']).to eq params[:issue][:text]
      end

      it "throws 415 unless JSON is sent" do
        params = { issue: { text: "Bad issuet" } }
        put "/api/issues/#{ issue.id }", params, @env
        expect(response.status).to eq(415)
      end

      it "throws 422 if issue is invalid" do
        params = { issue: { text: "B"*(65535+1) } }
        put "/api/issues/#{ issue.id }", params.to_json, @env.merge("CONTENT_TYPE" => 'application/json')
        expect(response.status).to eq(422)
      end
    end

    describe "DELETE /api/issue/:id" do
      let(:issue) { create(:issue) }

      it "deletes a issue" do
        delete "/api/issues/#{ issue.id }", {}, @env
        expect(response.status).to eq(200)

        expect { Issue.find(issue.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

  end
end
