$:.push File.expand_path('../lib', __FILE__)

require 'dradis/plugins/echo/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.platform = Gem::Platform::RUBY
  spec.name = 'dradis-echo'
  spec.version = Dradis::Plugins::Echo::VERSION::STRING
  spec.summary = 'This plugin adds Echo, an AI copilot for Dradis.'
  spec.description = 'Prompt your existing project for insight and reporting help. Get advice on what to try next.'

  spec.license = 'GPL-2'

  spec.authors = ['Daniel Martin']
  spec.homepage = 'https://dradis.com/support/'

  spec.files = `git ls-files`.split($\)
  spec.executables = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_dependency 'dradis-plugins', '~> 4.0'
  spec.add_dependency 'liquid'
  spec.add_dependency 'ollama-ai', '~> 1.3.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
