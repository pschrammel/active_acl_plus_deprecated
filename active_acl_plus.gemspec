# -*- encoding: utf-8 -*-
require 'rake'

PKG_NAME='activeaclplus'
PKG_VERSION= "0.4.0"
PKG_FILE_NAME	  = "#{PKG_NAME}-#{PKG_VERSION}"

PKG_GEM=Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name     = PKG_NAME
  s.version  = PKG_VERSION

  s.authors  = ["Peter Schrammel","Gregor Melhorn"]
  s.date     = Date.today.to_s
  s.description = %q{A flexible, fast and easy to use generic access control system.}
  s.email    = ["peter.schrammel@gmx.de"]
  s.rubyforge_project = "activeaclplus"
  s.summary  = "A new Version (#{PKG_VERSION}) of ActiveAclPlus is available."
  s.homepage = "http://activeaclplus.rubyforge.org/"
  extra_rdoc_files = ["README.rdoc","LICENSE","CHANGELOG"]
  s.files	= FileList["{lib,tasks,generators,db,app}/**/*"].to_a + %w(init.rb install.rb Rakefile) + extra_rdoc_files
  s.require_paths = ["lib"]
  
  #RDOC
  s.has_rdoc         = true
  s.extra_rdoc_files = extra_rdoc_files
  s.rdoc_options     = [ "--title", "Active Acl Plus", "--main", "README.rdoc"]

  #DEPENDENCIES
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=  
  s.add_dependency	"rails", ">= 2.1.0"
end

PKG_GEM