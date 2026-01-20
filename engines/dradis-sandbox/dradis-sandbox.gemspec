# -*- encoding: utf-8 -*-

require_relative 'lib/dradis/sandbox/version'
version = Dradis::Sandbox.version

Gem::Specification.new do |gem|
  gem.platform      = Gem::Platform::RUBY
  gem.name          = 'dradis-sandbox'
  gem.version       = version
  gem.required_ruby_version = '>= 1.9.3'
  gem.license       = 'GPL-2'

  gem.authors       = ['Dradis Team']
  gem.email         = ['>moc.stoorytiruces@liame<'.reverse]
  gem.description   = 'Sandbox environmet for Dradis Framework Community Eddition'
  gem.summary       = 'Dradis CE Sandbox'
  gem.homepage      = 'https://dradis.com/ce/'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
