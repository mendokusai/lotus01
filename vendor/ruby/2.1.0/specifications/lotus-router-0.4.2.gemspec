# -*- encoding: utf-8 -*-
# stub: lotus-router 0.4.2 ruby lib

Gem::Specification.new do |s|
  s.name = "lotus-router"
  s.version = "0.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Luca Guidi", "Trung L\u{ea}", "Alfonso Uceda Pompa"]
  s.date = "2015-07-10"
  s.description = "Rack compatible HTTP router for Ruby"
  s.email = ["me@lucaguidi.com", "trung.le@ruby-journal.com", "uceda73@gmail.com"]
  s.homepage = "http://lotusrb.org"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.4.6"
  s.summary = "Rack compatible HTTP router for Ruby and Lotus"

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<http_router>, ["~> 0.11"])
      s.add_runtime_dependency(%q<lotus-utils>, [">= 0.5.1", "~> 0.5"])
      s.add_development_dependency(%q<bundler>, ["~> 1.5"])
      s.add_development_dependency(%q<minitest>, ["~> 5"])
      s.add_development_dependency(%q<rake>, ["~> 10"])
    else
      s.add_dependency(%q<http_router>, ["~> 0.11"])
      s.add_dependency(%q<lotus-utils>, [">= 0.5.1", "~> 0.5"])
      s.add_dependency(%q<bundler>, ["~> 1.5"])
      s.add_dependency(%q<minitest>, ["~> 5"])
      s.add_dependency(%q<rake>, ["~> 10"])
    end
  else
    s.add_dependency(%q<http_router>, ["~> 0.11"])
    s.add_dependency(%q<lotus-utils>, [">= 0.5.1", "~> 0.5"])
    s.add_dependency(%q<bundler>, ["~> 1.5"])
    s.add_dependency(%q<minitest>, ["~> 5"])
    s.add_dependency(%q<rake>, ["~> 10"])
  end
end
