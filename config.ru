# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

Rails.application.load_server

# map block prepends routes with '/pro' in production.
# config.relative_url_root is set automatically by Rails when we set ENV['RAILS_RELATIVE_URL_ROOT'] in the puma config
# or by config.relative_url_root in production.rb
#
# Currently, we have specific references to '/pro' in the following places:
# - production.rb -> config.relative_url_root & action_cable.mount_path
# - nginx.conf -> locations: /pro, /pro/cable, /pro/assets
# - smtp.yml.template
#
# These will need to be updated when we update our configurations for Docker deployment
map Rails.application.config.relative_url_root || '/' do
  run Rails.application
end

# Mount the Resque web interface in development. In production is already
# available through the CIC.
#
# if defined?(Rails) && Rails.env.development?
#   map '/jobs' do
#     run Resque::Server
#   end
# end
