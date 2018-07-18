# -*- encoding: utf-8 -*-

require File.expand_path('../lib/dradis/ce/api/version', __FILE__)
version = Dradis::CE::API.version

Gem::Specification.new do |gem|
  gem.platform      = Gem::Platform::RUBY
  gem.name          = 'dradis-api'
  gem.version       = version
  gem.required_ruby_version = '>= 1.9.3'
  gem.license       = 'GPL-2'

  gem.authors       = ['Daniel Martin']
  gem.email         = ['etd@nomejortu.com.com>']
  gem.description   = 'REST HTTP API for Dradis Framework'
  gem.summary       = 'Dradis HTTP API'
  gem.homepage      = 'http://dradisframework.org'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'jbuilder'#, '~> 2.3.1'

  gem.add_development_dependency 'capybara', '~> 1.1.3'
  gem.add_development_dependency 'database_cleaner'
  gem.add_development_dependency 'factory_girl_rails'
  gem.add_development_dependency 'rspec-rails',  '~> 2.11.0'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'webmock'
end
