# frozen_string_literal: true

Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.dsn = ENV['SENTRY_DSN']
  #config.traces_sample_rate = 1.0
  #config.profiles_sample_rate = 1.0
  config.send_default_pii = false
end if Rails.env.sandbox?
