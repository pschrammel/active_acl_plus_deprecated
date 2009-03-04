module ActiveAcl
  
  
end

# plugin dependency
require 'has_many_polymorphs'

require 'active_acl/options'
require 'active_acl/base'

require 'active_acl/privilege_const_set'
require 'active_acl/grant'

require 'active_acl/handler/object_handler'
require 'active_acl/handler/nested_set'
require 'active_acl/db/active_record_adapter'
require 'active_acl/cache/no_cache_adapter'
require 'active_acl/load_controller_actions'
require 'active_acl/acts_as_access_object'
require 'active_acl/acts_as_access_group'
require 'active_acl/load_files_from'


# call class so its loaded and registered as access object
# wrap in rescue block so migrations don't fail
begin
  ActiveAcl::ControllerAction
  ActiveAcl::ControllerGroup
rescue StandardError => e
  puts "Error #{e.message} #{e.backtrace.join("\n")}(need migrations?)"
end