require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/sshpublisher'

# RCOV command, run as though from the commandline.
RCOV = "rcov" 

PKG_NAME		   = "active_acl"
PKG_VERSION		= "0.2.1"
PKG_FILE_NAME	  = "#{PKG_NAME}-#{PKG_VERSION}"
RUBY_FORGE_PROJECT = "activeacl"
RUBY_FORGE_USER = "hildolfur"

spec = Gem::Specification.new do |s|
  s.name			= PKG_NAME
  s.version		 = PKG_VERSION
  s.platform		= Gem::Platform::RUBY
  s.summary		 = "Provides an unintrusive, scalable and very flexible approach to fine grained access control."
  s.files		   = FileList["{lib,tasks,generators,db}/[^.]**/[^.]*"].to_a + %w(init.rb install.rb LICENSE Rakefile README CHANGELOG)
  s.require_path	= "lib"
  s.autorequire	 = PKG_NAME
  s.has_rdoc		= true
  s.add_dependency	"rails", ">= 1.1.6"
  s.author		  = "Gregor Melhorn"
  s.email		   = "g.melhorn@web.de"
  s.homepage		= "http://activeacl.rubyforge.org"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

desc 'Default: run unit tests.'
task :default => :test

#desc "Publish the beta gem"
#task :pgem => [:package] do
#  Rake::SshFilePublisher.new("pluginaweek@pluginaweek.org", "/home/pluginaweek/gems.pluginaweek.org/gems", "pkg", "#{PKG_FILE_NAME}.gem").upload
#end

desc "Publish the API documentation"
task :pdoc => [:rdoc] do
  Rake::SshDirPublisher.new("hildolfur@rubyforge.org", "/var/www/gforge-projects/activeacl/api", "rdoc").upload
  #Rake::RubyForgePublisher.new(RUBY_FORGE_PROJECT, RUBY_FORGE_USER).upload
end

desc "Publish the API docs and gem"
task :publish => [:pdoc, :release]

desc "Publish the release files to RubyForge."
task :release => [:gem, :package] do
  require 'rubyforge'
  options = {"cookie_jar" => RubyForge::COOKIE_F}
  options["password"] = ENV["RUBY_FORGE_PASSWORD"] if ENV["RUBY_FORGE_PASSWORD"]
  ruby_forge = RubyForge.new("./config.yml", options)
  ruby_forge.login
  %w( gem tgz zip ).each do |ext|
	file = "pkg/#{PKG_FILE_NAME}.#{ext}"
	puts "Releasing #{File.basename(file)}..."
	ruby_forge.add_release(RUBY_FORGE_PROJECT, PKG_NAME, PKG_VERSION, file)
  end
end

desc "generate a coverage report"
task :coverage do
  sh "#{RCOV} --rails -T -Ilib -x db/**/* --output ../../../coverage/active_acl test/all_tests.rb"
end

desc "generate a coverage report saving current state"
task :coverage_save do
  sh "#{RCOV} --rails -T -Ilib -x db/**/* --output ../../../coverage/active_acl --save ../../../coverage/active_acl/coverage.info test/all_tests.rb"
end

desc "generate a diff coverage report on previously saved state"
task :coverage_diff do
  sh "#{RCOV} --rails -T -Ilib -x db/**/* --text-coverage-diff ../../../coverage/active_acl/coverage.info --output ../../../coverage/active_acl test/all_tests.rb"
end

desc 'Test the active_acl plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/unit/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the active_acl plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'GaclBase'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
