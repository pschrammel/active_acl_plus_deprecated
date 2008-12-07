# -*- encoding: utf-8 -*-
require 'rake'

PKG_NAME='activeaclplus'
PKG_VERSION= "0.3.0"
PKG_FILE_NAME	  = "#{PKG_NAME}-#{PKG_VERSION}"

PKG_GEM=Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter Schrammel","Gregor Melhorn"]
  s.date = %q{2008-12-07}
  s.description = %q{A flexible, fast and easy to use generic access control system.}
  s.email = ["peter.schrammel@gmx.de"]
  s.platform		= Gem::Platform::RUBY
  s.extra_rdoc_files = []
  s.files	= FileList["{lib,tasks,generators,db}/[^.]**/[^.]*"].to_a + %w(init.rb install.rb LICENSE Rakefile README.rdoc CHANGELOG)
  s.has_rdoc = true
  s.homepage = %q{http://activeaclplus.rubyforge.org/}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{activeaclplus}
  s.rubygems_version = %q{0.3.0}
  s.summary = %q{activeaclplus 0.3.0}
  s.add_dependency	"rails", ">= 2.1.0"
end

PKG_GEM