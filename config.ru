# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

map ENV['RAILS_RELATIVE_URL_ROOT'] || '/' do
  run Rails.application
end

# Mount the Resque web interface in development. In production is already
# available through the CIC.
if defined?(Rails) && Rails.env.development?
  map '/jobs' do
    run Resque::Server
  end
end