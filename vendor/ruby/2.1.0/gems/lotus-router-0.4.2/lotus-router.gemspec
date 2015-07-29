# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lotus/router/version'

Gem::Specification.new do |spec|
  spec.name          = 'lotus-router'
  spec.version       = Lotus::Router::VERSION
  spec.authors       = ['Luca Guidi', 'Trung Lê', 'Alfonso Uceda Pompa']
  spec.email         = ['me@lucaguidi.com', 'trung.le@ruby-journal.com', 'uceda73@gmail.com']
  spec.description   = %q{Rack compatible HTTP router for Ruby}
  spec.summary       = %q{Rack compatible HTTP router for Ruby and Lotus}
  spec.homepage      = 'http://lotusrb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md lotus-router.gemspec`.split($/)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'http_router', '~> 0.11'
  spec.add_dependency 'lotus-utils', '~> 0.5', '>= 0.5.1'

  spec.add_development_dependency 'bundler',  '~> 1.5'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'rake',     '~> 10'
end
