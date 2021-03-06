# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lotus/helpers/version'

Gem::Specification.new do |spec|
  spec.name          = 'lotus-helpers'
  spec.version       = Lotus::Helpers::VERSION
  spec.authors       = ['Luca Guidi', 'Trung Lê']
  spec.email         = ['me@lucaguidi.com', 'trung.le@ruby-journal.com']
  spec.summary       = %q{Lotus helpers}
  spec.description   = %q{View helpers for Ruby applications}
  spec.homepage      = 'http://lotusrb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -- lib/* LICENSE.md README.md lotus-helpers.gemspec`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'lotus-utils', '~> 0.5'

  spec.add_development_dependency 'bundler',  '~> 1.6'
  spec.add_development_dependency 'rake',     '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.5'
end
