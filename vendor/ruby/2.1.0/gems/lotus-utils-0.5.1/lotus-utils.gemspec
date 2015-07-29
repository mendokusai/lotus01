# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lotus/utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'lotus-utils'
  spec.version       = Lotus::Utils::VERSION
  spec.authors       = ['Luca Guidi', 'Trung Lê', 'Alfonso Uceda Pompa']
  spec.email         = ['me@lucaguidi.com', 'trung.le@ruby-journal.com', 'uceda73@gmail.com']
  spec.description   = %q{Lotus utilities}
  spec.summary       = %q{Ruby core extentions and Louts utilities}
  spec.homepage      = 'http://lotusrb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md lotus-utils.gemspec`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler',  '~> 1.6'
  spec.add_development_dependency 'rake',     '~> 10'
  spec.add_development_dependency 'minitest', '~> 5.4'
end
