# -*- encoding: utf-8 -*-
# stub: lotus-controller 0.4.4 ruby lib

Gem::Specification.new do |s|
  s.name = "lotus-controller"
  s.version = "0.4.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Luca Guidi", "Trung L\u{ea}"]
  s.date = "2015-06-23"
  s.description = "Complete, fast and testable actions for Rack"
  s.email = ["me@lucaguidi.com", "trung.le@ruby-journal.com"]
  s.homepage = "http://lotusrb.org"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.4.6"
  s.summary = "Complete, fast and testable actions for Rack and Lotus"

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, ["~> 1.5"])
      s.add_runtime_dependency(%q<lotus-utils>, ["~> 0.5"])
      s.add_runtime_dependency(%q<lotus-validations>, ["~> 0.3"])
      s.add_development_dependency(%q<bundler>, ["~> 1.6"])
      s.add_development_dependency(%q<minitest>, ["~> 5"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.6"])
      s.add_development_dependency(%q<rake>, ["~> 10"])
    else
      s.add_dependency(%q<rack>, ["~> 1.5"])
      s.add_dependency(%q<lotus-utils>, ["~> 0.5"])
      s.add_dependency(%q<lotus-validations>, ["~> 0.3"])
      s.add_dependency(%q<bundler>, ["~> 1.6"])
      s.add_dependency(%q<minitest>, ["~> 5"])
      s.add_dependency(%q<rack-test>, ["~> 0.6"])
      s.add_dependency(%q<rake>, ["~> 10"])
    end
  else
    s.add_dependency(%q<rack>, ["~> 1.5"])
    s.add_dependency(%q<lotus-utils>, ["~> 0.5"])
    s.add_dependency(%q<lotus-validations>, ["~> 0.3"])
    s.add_dependency(%q<bundler>, ["~> 1.6"])
    s.add_dependency(%q<minitest>, ["~> 5"])
    s.add_dependency(%q<rack-test>, ["~> 0.6"])
    s.add_dependency(%q<rake>, ["~> 10"])
  end
end
