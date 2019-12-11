source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.7'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Cache-friendly, client-side local time
gem 'local_time', '>= 2.0.0'


# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# ---------------------------------------------------- Dradis Community Edition
gem 'bootstrap-sass', '~> 2.3.2.2'
gem 'font-awesome-sass', '~> 4.7.0'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-fileupload-rails', '~> 0.3.4'
gem 'jquery-hotkeys-rails'

# Organize Node tree
gem 'acts_as_tree', '~> 2.7.1'

gem 'builder'

gem 'differ', '~> 0.1.2'


# HTML processing filters and utilities
gem 'html-pipeline'

gem 'kaminari', '~> 1.0.1'

gem 'paper_trail', '~> 6.0'

# gem 'rails_autolink', '~> 1.1'

gem 'record_tag_helper'

gem 'rubyzip', '>= 1.2.2'

gem 'thor', '~> 0.18'


# ------------------------------------------------------ With native extensions
# These require native extensions.
# Ensure Traveling Ruby provides an appropriate version before bumping.
# See:
#   http://traveling-ruby.s3-us-west-2.amazonaws.com/list.html

# Use ActiveModel has_secure_password
# Password digests
gem 'bcrypt',   '3.1.12'

# Required by Rails (uglifier and activesupport)
gem 'json', '1.8.6'

# XML manipulation
gem 'nokogiri', '1.10.5'

# MySQL backend
gem 'mysql2', '~> 0.5.1'

# actionpack depends on rails-html-sanitizer, which has an XSS vulnerability
# before 1.0.4, so make sure we're using 1.0.4+:
# see https://github.com/rails/rails-html-sanitizer/commit/f3ba1a839a
# and https://github.com/flavorjones/loofah/issues/144
gem 'rails-html-sanitizer', '~> 1.0.4'

# Textile markup
gem 'RedCloth', '~> 4.3.2', require: 'redcloth'

# html-pipeline dependency for auto-linking
gem 'rinku'

# html-pipeline dependency for html sanitization
gem 'sanitize'

# SQLite3 DB driver
gem 'sqlite3'#,  '1.3.10'

# --------------------------------------------------------- Dradis Professional
# Authorisation
gem 'cancancan', '~> 1.10'

# Redis-based background worker
gem 'resque', require: 'resque/status_server'
gem 'resque-status'
# See https://github.com/sinatra/sinatra/issues/1055
gem 'sinatra', '2.0.2'

# Forms that integrate with Twitter's Bootstrap
gem 'simple_form'

# Word content control filter string parsing
gem 'parslet', '~> 1.6.0'

# Word screenshots processing
gem 'image_size', '~> 1.3.0'

# Handle authentication at the Rack level
gem 'warden', '~> 1.2.3'

# Schedule cron jobs
gem 'whenever', require: false



# ------------------------------------------------------------------ Deployment
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :production do
  # Use Unicorn as the web server
  gem 'unicorn',  '5.4.1'
end


# ----------------------------------------------------- Development and Testing
group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # guard-rspec depends on `guard`, which depends on `listen`, but versions of
  # listen higher than 3.1.1 require Ruby version >= 2.2.3 (we're currently on
  # 2.2.2). Restrict the version of `listen` to prevent `guard-rspec`
  # introducing an incompatible dependency:
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Alert on n+1 queries
  gem 'bullet'

  # Cleanup logs from asset entries
  # gem 'quiet_assets'

  # manage background workers
  gem 'foreman'
  gem 'rerun'
  # opens ActionMailer messages in the browser
  gem 'letter_opener'
  #gem 'ruby-debug'

  # security
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false

  gem 'rubocop', require: false
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  gem 'rspec-rails', '~> 3.1'

  gem 'puma'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'capybara'
  gem 'guard-rspec', require: false
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'timecop'
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# =================================================== Other plugins and engines
# = ~  Do not edit this file!! ~ ==============================================
# =============================================================================
#
# See Gemfile.plugins to edit the list of plugins and tool connectors that will
# be loaded by the framework.
#
# Plugins in Gemfile.plugins will be loaded automatically, that's where your
# own plugins should be listed.
#

# Base framework classes required by other plugins
gem 'dradis-plugins', '~> 3.15'


gem 'dradis-api', path: 'engines/dradis-api'

# Import / export project data
gem 'dradis-projects', '~> 3.15'

plugins_file = 'Gemfile.plugins'
if File.exists?(plugins_file)
  eval(IO.read(plugins_file), binding)
end
