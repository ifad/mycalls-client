# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require 'my_calls/client/version'

Gem::Specification.new do |s|
  s.name              = 'mycalls-client'
  s.version           = MyCalls::Client::VERSION
  s.summary           = "A Ruby client for the MyCalls web service."
  s.description       = "A Ruby client for IFAD MyCalls Application's REST API."

  s.author            = ["Lleir Borras"]
  s.email             = ["l.borrasmetje@ifad.org"]
  s.homepage          = "http://mine.ifad.org/git/mycalls-client"

  s.files             = `git ls-files`.split("\n")
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("typhoeus", "~> 0.6")
  s.add_dependency("multi_json")
  s.add_dependency("activesupport", ">= 3.0")
  s.add_dependency("dalli")

  # If your tests use any gems, include them here
  s.add_development_dependency("rr", ">= 1.0.0")
  s.add_development_dependency("rspec", ">= 2.5.0")
  s.add_development_dependency("yard")
  s.add_development_dependency("redcarpet")
  s.add_development_dependency("rake")
  s.add_development_dependency("debugger")
end
