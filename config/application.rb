require_relative 'boot'

# Pick the frameworks you want:
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dradis
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %w(
      lib
    ).map { |path| "#{config.root}/#{path}" }

    # Fix relative URLs for mounted engines.
    # See:
    #   https://github.com/activeadmin/activeadmin/issues/101#issuecomment-22273869
    #
    # TODO: possibly fixed by Rails 4?
    routes.default_url_options[:script_name] = ActionController::Base.config.relative_url_root || '/'
  end
end

require 'dradis/ce'
