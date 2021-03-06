# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dotfiles_installer/version"

Gem::Specification.new do |s|
  s.name        = "dotfiles-installer"
  s.version     = DotfilesInstaller::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kelly Redding"]
  s.email       = ["kelly@kelredd.com"]
  s.homepage    = "http://github.com/kelredd/dotfiles-installer"
  s.summary     = %q{Safely install dotfiles into your home dir.}
  s.description = %q{Safely install dotfiles into your home dir.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("bundler")
  s.add_development_dependency("assert")

  s.add_dependency("ansi", ["~> 1.3"])
end
