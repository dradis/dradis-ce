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
      Warden::Strategies.add(:basic_auth, Dradis::CE::API::BasicAuthStrategy)
      Warden::Strategies.add(:token_auth, Dradis::CE::API::ApiTokenStrategy)
    end

    initializer 'dradis-api.extend_models' do
      ActiveSupport.on_load :user_model do
        User.send(:include, Dradis::CE::API::Concerns::APIAuthenticatable)
      end
    end

    initializer 'dradis-api.insert_middleware' do |app|
      app.config.middleware.insert_before Warden::Manager, Dradis::CE::API::CatchJsonParseErrors
    end

    initializer 'dradis-api.append_migrations' do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"].push(path)
        end
      end
    end

    initializer 'dradis-api.mount_engine' do
      Rails.application.routes.append do
        mount Dradis::CE::API::Engine => '/', as: :dradis_api
      end
    end

  end
end
