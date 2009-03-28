# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{active_acl_plus}
  s.version = "0.4.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter Schrammel", "Gregor Melhorn"]
  s.date = %q{2009-03-28}
  s.description = %q{A flexible, fast and easy to use generic access control system.}
  s.email = ["peter.schrammel@gmx.de"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "CHANGELOG"]
  s.files = ["README.rdoc", "VERSION.yml", "lib/active_acl", "lib/active_acl/db", "lib/active_acl/db/mysql_adapter.rb", "lib/active_acl/db/active_record_adapter.rb", "lib/active_acl/cache", "lib/active_acl/cache/no_cache_adapter.rb", "lib/active_acl/cache/memcache_adapter.rb", "lib/active_acl/handler", "lib/active_acl/handler/object_handler.rb", "lib/active_acl/handler/nested_set.rb", "lib/active_acl/load_files_from.rb", "lib/active_acl/options.rb", "lib/active_acl/load_controller_actions.rb", "lib/active_acl/privilege_const_set.rb", "lib/active_acl/acts_as_access_group.rb", "lib/active_acl/grant.rb", "lib/active_acl/base.rb", "lib/active_acl/acts_as_access_object.rb", "lib/active_acl.rb", "app/models", "app/models/active_acl", "app/models/active_acl/acl_section.rb", "app/models/active_acl/controller_group.rb", "app/models/active_acl/privilege.rb", "app/models/active_acl/requester_group_link.rb", "app/models/active_acl/requester_link.rb", "app/models/active_acl/target_group_link.rb", "app/models/active_acl/target_link.rb", "app/models/active_acl/controller_action.rb", "app/models/active_acl/acl.rb", "db/migrate", "db/migrate/001_base_table_setup.rb", "LICENSE", "CHANGELOG"]
  s.has_rdoc = true
  s.homepage = %q{http://activeaclplus.rubyforge.org/}
  s.rdoc_options = ["--title", "Active Acl Plus", "--main", "README.rdoc", "--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{activeaclplus}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A new Version of ActiveAclPlus is available.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
