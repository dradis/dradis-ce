# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'capybara/rspec'

require "capybara/poltergeist"

Capybara.register_driver :poltergeist do |app|
  options = { js_errors: false, timeout: 30, window_size: [1920, 1080] }
  Capybara::Poltergeist::Driver.new(app, options)
end

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
  config.include ControllerMacros, type: :feature
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

  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.example_status_persistence_file_path = Rails.root.join("spec", ".examples.txt")

  # Stop GC while we test
  config.before(:all) { DeferredGarbageCollection.start }
  config.after(:all) { DeferredGarbageCollection.reconsider }

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
