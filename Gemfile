source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0.4'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'

# Use ruby-terser as compressor for JavaScript assets
gem 'terser', '~> 1.1'

# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'

# Cache-friendly, client-side local time
gem 'local_time', '>= 2.0.0'

gem 'turbo-rails', '~> 2.0'
gem 'stimulus-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.13'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.12.0', require: false

# ---------------------------------------------------- Dradis Community Edition
gem 'bootstrap', '~> 5.2.3'
gem 'jquery-rails'
gem 'jquery-fileupload-rails', '~> 0.3.4'
gem 'jquery-hotkeys-rails'

# Sortable lists
gem 'acts_as_list', '~> 0.7.5'

# Organize Node tree
gem 'acts_as_tree', '~> 2.9.1'

gem 'builder'

gem 'differ', '~> 0.1.2'

# HTML processing filters and utilities
gem 'html-pipeline'
gem 'liquid'

gem 'kaminari', '~> 1.2.1'

gem 'paper_trail', '~> 16.0'

# gem 'rails_autolink', '~> 1.1'

gem 'record_tag_helper'

gem 'rubyzip', '>= 1.2.2'

gem 'thor', '~> 1.4.0'

gem 'thruster'

# Ruby dependency, version specified here due to CVE-2023-28756
gem 'time', '>= 0.2.2'

gem 'font-awesome-sass', '~> 6.4.0'

gem 'importmap-rails', '~> 1.2'

gem 'sprockets-rails', '>= 3.0.0'

# ------------------------------------------------------ With native extensions
# These require native extensions.
# Ensure Traveling Ruby provides an appropriate version before bumping.
# See:
#   http://traveling-ruby.s3-us-west-2.amazonaws.com/list.html

# Use Active Model has_secure_password
# Password digests
gem 'bcrypt', '3.1.12'

# Required by Rails (uglifier and activesupport)
gem 'json', '2.3.0'

# XML manipulation
gem 'nokogiri', '>= 1.18.9'

# MySQL backend
# gem 'mysql2', '~> 0.5.6'

# actionpack depends on rails-html-sanitizer, which has an XSS vulnerability
# before 1.0.4, so make sure we're using 1.0.4+:
# see https://github.com/rails/rails-html-sanitizer/commit/f3ba1a839a
# and https://github.com/flavorjones/loofah/issues/144
gem 'rails-html-sanitizer', '~> 1.6.1'

# Textile markup
gem 'RedCloth', '~> 4.3.4', require: 'redcloth'

# html-pipeline dependency for auto-linking
gem 'rinku'

# html-pipeline dependency for html sanitization
gem 'sanitize', '6.0.2'

# SQLite3 DB driver
gem 'sqlite3'
# gem 'pg'

# --------------------------------------------------------- Dradis Professional
# Authorisation
gem 'cancancan', '~> 1.10'

# Redis-based background worker
gem 'resque'

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

gem 'net-smtp'
gem 'net-pop'
gem 'net-imap', '>= 0.5.7'

gem 'puma', '>= 6.5.0'

gem 'csv'

# ------------------------------------------------------------------ Deployment
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# ----------------------------------------------------- Development and Testing
group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Alert on n+1 queries
  #gem 'bullet'

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
  # required by brakeman
  gem 'abbrev'

  gem 'bundler-audit', require: false
  gem 'ruby_audit', '~> 3.0.0', require: false

  gem 'rubocop', '1.79.0', require: false
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # rspec-rails < 7.0.0 does not support rails 7.2
  gem 'rspec-rails', '~> 7.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 6.5'
  gem 'capybara', '~> 3.40'
  gem 'guard-rspec', require: false
  gem 'selenium-webdriver', '~> 4.35'
  gem 'shoulda-matchers', '~> 4.0.1'
  gem 'timecop'

  # Required by capybara
  gem 'matrix'
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
gem 'dradis-plugins', '~> 4.18.0'

gem 'dradis-api', path: 'engines/dradis-api'

# Import / export project data
gem 'dradis-projects', '~> 4.18.0'

gem 'dradis-echo', github: 'dradis/dradis-echo', branch: 'release-4.19.0'

plugins_file = 'Gemfile.plugins'
if File.exist?(plugins_file)
  eval(IO.read(plugins_file), binding)
end

# For now keep a hard-coded list of plugins until Gemfile.plugins becomes fully
# effective.

# ----------------------------------------------------------------- Calculators

gem 'dradis-calculator_cvss', '~> 4.18.0'
gem 'dradis-calculator_dread', '~> 4.18.0'
gem 'dradis-calculator_mitre', '~> 4.18.0'

# ---------------------------------------------------------------------- Export
gem 'dradis-csv_export', '~> 4.18.0'
gem 'dradis-html_export', '~> 4.18.0'

# ---------------------------------------------------------------------- Import
gem 'dradis-csv', '~> 4.18.0'

# ---------------------------------------------------------------------- Upload
gem 'dradis-acunetix', '~> 4.18.0'
gem 'dradis-brakeman', '~> 4.18.0'
gem 'dradis-burp', '~> 4.18.0'
gem 'dradis-coreimpact', '~> 4.18.0'
gem 'dradis-metasploit', '~> 4.18.0'
gem 'dradis-nessus', '~> 4.18.0'
gem 'dradis-netsparker', '~> 4.18.0'
gem 'dradis-nexpose', '~> 4.18.0'
gem 'dradis-nikto', '~> 4.18.0'
gem 'dradis-nipper', '~> 4.18.0'
gem 'dradis-nmap', '~> 4.18.0'
gem 'dradis-ntospider', '~> 4.18.0'
gem 'dradis-openvas', '~> 4.18.0'
gem 'dradis-pentera', '~> 4.18.0'
gem 'dradis-qualys', '~> 4.18.0'
gem 'dradis-saint', '~> 4.18.0'
gem 'dradis-veracode', '~> 4.18.0'
gem 'dradis-wpscan', '~> 4.18.0'
gem 'dradis-zap', '~> 4.18.0'
