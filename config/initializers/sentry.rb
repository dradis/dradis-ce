# frozen_string_literal: true

Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.dsn = ENV['SENTRY_DSN'] || 'https://43510613808863e359632bb142bfc857@o4510027522310144.ingest.de.sentry.io/4510027524931664'
  #config.traces_sample_rate = 1.0
  #config.profiles_sample_rate = 1.0
  config.send_default_pii = false
end if Rails.env.sandbox?
