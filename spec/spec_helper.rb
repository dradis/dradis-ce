# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'capybara/rspec'

require "capybara/poltergeist"
Capybara.javascript_driver = :poltergeist

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories, and in spec/support/ directories within
# engines and plugins
["", "engines/**/"].each do |dir|
  Dir[Rails.root.join("#{dir}spec/support/**/*.rb")].each {|f| require f}
end

RSpec.configure do |config|
  # Filter which specs to run
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # config.include ControllerMacros, type: :controller
  # config.include ControllerMacros, type: :feature
  # config.include SelecterHelper,   type: :feature
  # config.include SupportHelper,    type: :controller
  # config.include SupportHelper,    type: :feature
  # config.include SupportHelper,    type: :request
  config.include FactoryGirl::Syntax::Methods
  # config.include WaitForAjax, type: :feature

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    begin
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean_with(:truncation)
    end
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # When using JS, the Poltergeist driver needs to access the DB from an external
  # process, if we're in a transaction, stuff like newly created Users won't be
  # available to the driver
  #
  # See:
  #  https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
  #  http://devblog.avdi.org/2012/08/31/configuring-database_cleaner-with-rails-rspec-capybara-and-selenium/
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
