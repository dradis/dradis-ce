module Dradis::Sandbox
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Sandbox

    # Hook into the framework
    include ::Dradis::Plugins::Base
    provides :addon
    description 'Dradis CE Sandbox'

    initializer 'dradis-sandbox.assets' do |app|
      app.config.assets.precompile += [
        'dradis/sandbox/manifests/hera.css',
        'dradis/sandbox/manifests/hera.js'
      ]
    end

    initializer 'dradis-sandbox.mount_engine' do |app|
      app.routes.append do
        mount Dradis::Sandbox::Engine => '/', as: 'sandbox'
      end
    end

    initializer 'dradis-sandbox.append_seeds' do
      # Only append seeds when we're actually connected to a database
      # and it's ready (not during assets:precompile, etc.)
      if !ENV['SECRET_KEY_BASE_DUMMY']
        # This is a special case in which we want to overwrite the app's seeds
        # instead of appending to the collection.
        Rails.application.config.paths['db/seeds.rb'] = root.join('db/seeds.rb')
      end
    end

    initializer 'dradis-sandbox.sentry' do
      if !Rails.env.local? && ENV['SKIP_TELEMETRY'].blank?
        Sentry.init do |config|
          config.dsn = ENV['SENTRY_DSN']
          config.breadcrumbs_logger = %i[ active_support_logger http_logger ]
          config.send_default_pii = false
          # config.release = ENV["KAMAL_VERSION"]

          # Receive Rails.error.report and retry_on/discard_on report: true
          config.rails.register_error_subscriber = true
        end
      end
    end
  end
end
