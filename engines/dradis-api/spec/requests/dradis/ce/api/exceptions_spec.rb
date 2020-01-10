require 'rails_helper'

describe "API" do
  describe "Exceptions" do

    include_context "project scoped API"
    include_context "https"
    include_context "authorized API user"

    before do
      # To get the 'renders as HTML' test to work, we need to make show
      # that the 'show_exceptions' config setting is `true`, despite it
      # normally being set to `false` in the test ENV. The problem is that
      # Rails.application memoizes this config value the first time the
      # app receives a request (see
      # https://github.com/rails/rails/blob/v4.2.6/railties/lib/rails/application.rb#L253
      # ), and this memoization will persist between specs - which means that
      # if *any* other spec makes a request to the app before the specs in
      # this file get run, then stubbing 'show_exceptions' won't do anything
      # (because it won't overwrite the memoized value) and the spec will
      # fail.
      #
      # To get around this we're manually deleteing the memoized instance
      # variable within Rails.application using remove_instance_variable. This
      # is very hacky and may break without warning in future versions of Rails
      # (at the time of writing we're using 4.2.6).

      @show_exceptions_prev_val = Rails.application.config.action_dispatch.show_exceptions
      # @app_env_config might not necessarily be defined, and
      # remove_instance_variable will raise an error if it's not:
      if Rails.application.instance_variable_get '@app_env_config'
        Rails.application.remove_instance_variable '@app_env_config'
      end
      Rails.application.config.action_dispatch.show_exceptions = true
    end

    after do
      # We need to reset the cached variable again, otherwise our stubbed value
      # will be persisted to other specs and we'd have the same problem but in
      # reverse.
      Rails.application.remove_instance_variable '@app_env_config'
      Rails.application.config.action_dispatch.show_exceptions = @show_exceptions_prev_val
    end

    describe "404 - Not Found" do
      it "renders as JSON if it happens inside the API" do
        get "/api/issues/12345", env: @env

        expect(response.status).to eq(404)
        expect(response.headers.keys).not_to include('Set-Cookie')

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
  end

end
