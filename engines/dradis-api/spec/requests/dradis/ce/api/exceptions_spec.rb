require 'spec_helper'

describe "API" do


  describe "Exceptions" do

    before(:each) do
      allow(Rails.application.config.action_dispatch).to receive(:show_exceptions).and_return true
      allow(Rails.application.config).to receive(:consider_all_requests_local).and_return false
      allow(Configuration).to receive(:shared_password).and_return(::BCrypt::Password.create('rspec_pass'))
    end

    describe "500 - Internal Server Error" do

      it "renders as JSON if it happens inside the API" do
        expect(Node).to receive(:issue_library) do raise; end

        get "/api/issues", {}, api_env
        expect(response.status).to eq(500)
        expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')

        expect do
          body = JSON.parse(response.body)
        end.not_to raise_error
      end

      it "renders as html if it happens outside the API" do
        expect(SessionsController).to receive(:new) do raise; end
        get "/login"
        expect(response.status).to eq(500)
        expect(response.headers['Content-Type']).not_to eq('application/json; charset=utf-8')
      end
    end

    describe "404 - Not Found" do

      it "renders as JSON if it happens inside the API" do
        get "/api/issues/12345", {}, api_env
        expect(response.status).to eq(404)
        body = nil
        expect do
          body = JSON.parse(response.body)
        end.not_to raise_error
        expect(body[:message]).to eq(Rack::Utils::HTTP_STATUS_CODES[:not_found])
      end

      it "renders as html if it happens outside the API" do
        get "/bad_uri"
        expect(response.status).to eq(404)
        expect(response.headers['Content-Type']).not_to eq('application/json; charset=utf-8')
      end
    end


    def api_env
      {
        "HTTPS" => "on",
        "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials('rspec', 'rspec_pass'),
        "CONTENT_TYPE" => 'application/json'
      }
    end

  end

end
