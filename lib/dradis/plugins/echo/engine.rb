module Dradis::Plugins::Echo
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::Echo

    include Dradis::Plugins::Base
    provides :addon
    description 'Dradis AI Copilot'

    addon_settings :echo do
      settings.default_address = 'http://localhost:11434'
      settings.default_model = 'deepseek-r1:latest'
    end

    # add engine migrations to main app migrations paths in development
    if Rails.env.development?
      initializer 'dradis-echo.append_migrations' do |app|
        engine_migrations_path = config.paths['db/migrate'].expanded.first
        app.config.paths['db/migrate'].push(engine_migrations_path)
      end
    end

    initializer 'echo.asset_precompile_paths' do |app|
      app.config.assets.precompile += [
        'dradis/plugins/echo/manifests/hera.js'
      ]
    end

    initializer 'echo.extend_user_model' do
      ActiveSupport.on_load :user_model do
        ::User.send(:has_many, :prompts, class_name: 'Dradis::Plugins::Echo::Prompt', dependent: :destroy)
      end
    end

    initializer 'echo.mount_engine' do
      Rails.application.routes.append do
        # Enabling/disabling integrations calls Rails.application.reload_routes! we need the enable
        # check inside the block to ensure the routes can be re-enabled without a server restart
        if Engine.enabled?
          mount Engine, at: '/', as: :echo
        end
      end
    end

    # `before:` option has to be a string as it has to match
    # a named initializer exactly as a String or a Symbol
    # "importmap" is a string, you can see this list to check
    # the order of initializers:
    #   Rails.application.initializers.tsort.map(&:name)
    initializer 'echo.importmap', before: 'importmap' do |app|
      # https://github.com/rails/importmap-rails#composing-import-maps
      app.config.importmap.paths << root.join('config/importmap.rb')

      # https://github.com/rails/importmap-rails#sweeping-the-cache-in-development-and-test
      app.config.importmap.cache_sweepers << root.join('app/javascript')
    end
  end
end
