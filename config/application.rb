require_relative 'boot'

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dradis
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Fix relative URLs for mounted engines.
    # See:
    #   https://github.com/activeadmin/activeadmin/issues/101#issuecomment-22273869
    #
    # TODO: possibly fixed by Rails 4?
    routes.default_url_options[:script_name] = ActionController::Base.config.relative_url_root || '/'

    config.active_job.queue_adapter = :resque
  end
end

require 'dradis/ce'
