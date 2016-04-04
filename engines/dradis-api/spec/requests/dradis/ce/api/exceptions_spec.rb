require 'spec_helper'

describe "API" do


  describe "Exceptions" do

    before do
      allow(Rails.application.config.action_dispatch).to receive(:show_exceptions).and_return true
      allow(Rails.application.config.action_dispatch).to receive(:consider_all_requests_local).and_return false
      allow(Configuration).to receive(:shared_password).and_return(::BCrypt::Password.create('rspec_pass'))
    end

    describe "500 - Internal Server Error" do

      it "renders as JSON if it happens inside the API" do
        params = { project: { bad_attribute: "Bad attribute" } }
        expect(Dradis::Pro::API::ExceptionsController).to receive(:call)
        post "/api/projects", params.to_json, api_env
        expect(response.status).to eq(500)
        # puts response.body
        # puts "-----------------------------------------"
      end

      it "renders as html if it happens outside the API" do
        post session_path, login: @user.email, password: @user.password
        allow_any_instance_of(ProjectsController).to receive(:index).and_raise(ArgumentError)
        get "/projects"
        expect(response.status).to eq(500)
        # puts response.body
        # puts "-----------------------------------------"
      end
    end

    describe "404 - Not Found" do
      it "renders as JSON if it happens inside the API" do
        expect(Dradis::CE::API::ExceptionsController).to receive(:call)
        get "/api/issues/12345", {}, api_env
        expect(response.status).to eq(404)
        # puts response.body
        # puts "-----------------------------------------"
      end

      it "renders as html if it happens outside the API" do
        get "/bad_uri"
        expect(response.status).to eq(404)
        # puts response.body
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
