require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/sshpublisher'

# RCOV command, run as though from the commandline.
RCOV = "rcov" 

RUBY_FORGE_PROJECT = "activeaclplus"
RUBY_FORGE_USER = "popel"
PKG_NAME="active_acl_plus"


begin
  require 'jeweler'
    Jeweler::Tasks.new do |s|
      s.name     = 'active_acl_plus'
      s.authors  = ["Peter Schrammel","Gregor Melhorn"]
      s.description = %q{A flexible, fast and easy to use generic access control system.}
      s.email    = ["peter.schrammel@gmx.de"]
      s.rubyforge_project = RUBY_FORGE_PROJECT
      s.summary  = "A new Version of ActiveAclPlus is available."
      s.homepage = "http://activeaclplus.rubyforge.org/"
      s.extra_rdoc_files = ["README.rdoc","LICENSE","CHANGELOG"]
      s.rdoc_options     = [ "--title", "Active Acl Plus", "--main", "README.rdoc"]
      s.files = FileList["[A-Z]*.*","{lib,app,db}/**/*"]
   end
   rescue LoadError
   puts "Jeweler not available."
end


desc 'Default: run specs'
task :default => :spec

desc "Publish the API documentation"
task :pdoc => [:rdoc] do
  Rake::SshDirPublisher.new("popel@rubyforge.org", "/var/www/gforge-projects/activeaclplus/api", "rdoc").upload
  #Rake::RubyForgePublisher.new(RUBY_FORGE_PROJECT, RUBY_FORGE_USER).upload
end

desc "Publish the API docs and gem"
task :publish => [:pdoc, :release]

desc "Publish the release files to RubyForge."
task :release => [:gem, :package] do
  require 'rubyforge'
  options={}
  #options["cookie_jar"] = RubyForge::COOKIE_F
  #options["password"] = ENV["RUBY_FORGE_PASSWORD"] if ENV["RUBY_FORGE_PASSWORD"]
  
  ruby_forge = RubyForge.new
  ruby_forge.configure
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

begin #no spec or spec-rails? ok no tasks
  require 'spec/rake/spectask'
  
  desc 'Test the active_acl_plus plugin.'
  Spec::Rake::SpecTask.new(:spec) do |t|
    #t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
rescue LoadError => e
  puts "No spec tasks! - gem install rspec-rails (#{__FILE__})"
end

desc 'Generate documentation for the active_acl_plus plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ActiveAclPlus'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('CHANGELOG','LICENSE','README.rdoc','lib/**/*.rb','app/**/*.rb')
end

