require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

require 'resque/server'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dradis
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.assets.configure do |env|
      env.export_concurrent = false
    end
    config.action_view.form_with_generates_remote_forms = true
    config.after_initialize do
      config.active_record.yaml_column_permitted_classes = [
        ActiveModel::Errors,
        Symbol,
        UserPreferences
      ]
    end

    # Override the default credentials lookup paths. See bin/rails credentials:help
    config.credentials.content_path = Rails.root.join('config', 'shared', 'credentials.yml.enc')
    config.credentials.key_path = Rails.root.join('config', 'shared', 'master.key')
  end
end

require 'dradis/ce'
