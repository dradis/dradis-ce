module Dradis::Sandbox
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Sandbox

    # Hook into the framework
    include ::Dradis::Plugins::Base
    provides :addon
    description 'Dradis CE Sandbox'

    initializer 'dradis-sandbox.mount_engine' do |app|
      app.routes.append do
        mount Dradis::Sandbox::Engine => '/', as: 'sandbox'
      end
    end

    initializer 'dradis-sandbox.load_seed' do
      Engine.load_seed
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
