module Dradis::Plugins::Echo
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::Echo

    include Dradis::Plugins::Base
    provides :addon
    description 'Dradis AI Copilot'

    addon_settings :echo do
      settings.default_address = 'http://localhost:11434'
      settings.default_model = 'deepseek-r1:latest'

      settings.default_roslin_languagetool_address = 'http://localhost:8010'
      settings.default_roslin_enabled = false
      settings.default_roslin_teaser = true
    end

    # add engine migrations to main app migrations paths in development
    if Rails.env.development?
      initializer 'dradis-echo.append_migrations' do |app|
        engine_migrations_path = config.paths['db/migrate'].expanded.first
        app.config.paths['db/migrate'].push(engine_migrations_path)
      end
    end

    # initializer 'echo.asset_precompile_paths' do |app|
    #   app.config.assets.precompile += [
    #     'dradis/plugins/echo/manifests/application.css',
    #     'dradis/plugins/echo/manifests/application.js',
    #     'dradis/plugins/echo/manifests/hera.js'
    #   ]
    # end

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
  end
end
