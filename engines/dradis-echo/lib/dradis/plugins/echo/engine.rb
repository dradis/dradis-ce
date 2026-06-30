module Dradis::Plugins::Echo
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::Echo

    include Dradis::Plugins::Base
    provides :addon
    description 'Dradis AI Copilot'

    # add engine migrations to main app migrations paths
    initializer 'dradis-echo.append_migrations' do |app|
      engine_migrations_path = config.paths['db/migrate'].expanded.first
      app.config.paths['db/migrate'].push(engine_migrations_path)
    end

    initializer 'dradis-echo.append_seeds' do |app|
      app.class.set_callback(:load_seed, :after) do
        Dradis::Plugins::Echo::Engine.load_seed
      end
    end

    initializer 'echo.asset_precompile_paths' do |app|
      app.config.assets.paths << root.join('app/javascript')
      app.config.assets.precompile += [
        'dradis/plugins/echo/manifests/hera.js',
        'dradis/plugins/echo/anthropic.svg',
        'dradis/plugins/echo/gemini.svg',
        'dradis/plugins/echo/ollama.svg',
        'dradis/plugins/echo/open_ai.svg'
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

    # In production, Rails eager loads all classes at boot so provider subclasses
    # are always loaded before anything reads ALLOWED_TYPES (which is dynamically built).
    # In development, classes are lazy loaded, so we force-load the provider subclasses directory here to
    # ensure ALLOWED_TYPES is populated before the first request.
    config.to_prepare do
      Rails.autoloaders.main.eager_load_dir(
        Engine.root.join('app/models/dradis/plugins/echo/provider')
      )
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
