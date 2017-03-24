source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.2'

# Use Puma as the app server
# FIXME: required for Rails 5 ActionCable
# gem 'puma', '~> 3.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

gem 'bootstrap-sass', '~> 2.3.2.2'
gem 'font-awesome-sass', '~> 4.3.0'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-fileupload-rails', '~> 0.3.4'
gem 'jquery-hotkeys-rails'

# Cache-friendly, client-side local time
gem 'local_time'


# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'

# ---------------------------------------------------- Dradis Community Edition
# Organize Node tree
gem 'acts_as_tree'

gem 'builder'

gem 'differ', '~> 0.1.2'


# HTML processing filters and utilities
gem 'html-pipeline'

gem 'kaminari', '~> 0.16.1'

gem 'paper_trail', '~> 4.0.0'

# gem 'rails_autolink', '~> 1.1'

gem 'record_tag_helper'

gem 'thor', '~> 0.18'


# ------------------------------------------------------ With native extensions
# These require native extensions.
# Ensure Traveling Ruby provides an appropriate version before bumping.
# See:
#   http://traveling-ruby.s3-us-west-2.amazonaws.com/list.html

# Use ActiveModel has_secure_password
# Password digests
gem 'bcrypt',   '3.1.10'

# Required by Rails (uglifier and activesupport)
gem 'json', '1.8.2'

# XML manipulation
# TODO: Traveling Ruby - DANGER, DANGER: this version has an issue, but it's
# the last one supported by Traveling Ruby
# gem 'nokogiri', '1.6.6.2'
gem 'nokogiri', '1.7.1'

# MySQL backend
gem 'mysql2', '0.3.18'

# Textile markup

# TODO: Traveling Ruby - DANGER, DANGER: this version has an issue, but it's
# the last one supported by Traveling Ruby
# gem 'RedCloth', '4.2.9', require: 'redcloth'
gem 'RedCloth', '4.3.1', require: 'redcloth'

# html-pipeline dependency for auto-linking
gem 'rinku'

# SQLite3 DB driver
gem 'sqlite3'#,  '1.3.10'

# Use Unicorn as the web server
# FIXME: Switch to Puma for Rails 5
gem 'unicorn',  '4.9.0', group: :production


# --------------------------------------------------------- Dradis Professional
# Authorisation
gem 'cancancan', '~> 1.10'

# Redis-based background worker
gem 'resque', require: 'resque/status_server'
gem 'resque-status'
# See https://github.com/sinatra/sinatra/issues/1055
gem 'sinatra', '2.0.0.beta2'

# Forms that integrate with Twitter's Bootstrap
gem 'simple_form'

# Word content control filter string parsing
gem 'parslet', '~> 1.4.0'

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
end


# ----------------------------------------------------- Development and Testing
group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # guard-rspec depends on `guard`, which depends on `listen`, but versions of
  # listen higher than 3.1.1 require Ruby version >= 2.2.3 (we're currently on
  # 2.2.2). Restrict the version of `listen` to prevent `guard-rspec`
  # introducing an incompatible dependency:
  gem 'listen', '~> 3.0.5', '<= 3.1.1'

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
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  gem 'rspec-rails', '~> 3.1'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'guard-rspec', require: false
  gem 'shoulda-matchers', '~> 3.1'
  gem 'timecop'
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
gem 'dradis-plugins', '~> 3.6', github: 'dradis/dradis-plugins'


gem 'dradis-api', path: 'engines/dradis-api'

# Import / export project data
gem 'dradis-projects', '~> 3.6', github: 'dradis/dradis-projects'

plugins_file = 'Gemfile.plugins'
if File.exists?(plugins_file)
  eval(IO.read(plugins_file), binding)
end
