module Dradis::CE::API
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::CE::API

    # Hook into the framework
    include ::Dradis::Plugins::Base
    provides :addon
    description 'Dradis REST HTTP API'

    initializer "dradis-api.inflections" do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.acronym('API')
        inflect.acronym('CE')
      end
    end

    # Register a new Warden strategy for API authentication
    initializer 'dradis-api.warden' do
      Warden::Strategies.add(:api_auth, Dradis::CE::API::WardenStrategy)
    end

    initializer 'dradis-api.insert_middleware' do |app|
      app.config.middleware.insert_before ActionDispatch::ParamsParser, "Dradis::CE::API::CatchJsonParseErrors"
      # FIXME: Rails 5 removes the ParamsParser middleware, where should we hook to catch JSON parsing errors?
      # app.config.middleware.insert_before ActionDispatch::Flash, Dradis::CE::API::CatchJsonParseErrors
    end

    initializer 'dradis-api.mount_engine' do
      Rails.application.routes.append do
        mount Dradis::CE::API::Engine => '/', as: :dradis_api
      end
    end

  end
end
