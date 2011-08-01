# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "instapaper/version"

Gem::Specification.new do |s|
  s.name        = "instapaper-api"
  s.version     = Instapaper::VERSION
  s.authors     = ["Brian Mathiyakom"]
  s.email       = ["brian@rarevisions.net"]
  s.homepage    = ""
  s.summary     = %q{Thin Wrapper for the Instapaper Full API}
  s.description = %q{A work-in-progress library for interacting with the Instapaper Full Developer API. Use at your own risk. Feel free to fork the project. More about the Instapaper Full Developer API can be found at http://www.instapaper.com/api/full.}

  s.rubyforge_project = "instapaper-api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("typhoeus", "~> 0.2.4")
  s.add_dependency("simple_oauth", "~> 0.1.5")
  s.add_dependency("addressable", "~> 2.2.6")

  s.add_development_dependency("guard", "~> 0.5.1")
  s.add_development_dependency("rb-fsevent", "~> 0.4.1")
  s.add_development_dependency("rspec", "~> 2.6.0")
  s.add_development_dependency("guard-rspec", "~> 0.4.0")
  s.add_development_dependency("growl", "~> 1.0.3")
end
