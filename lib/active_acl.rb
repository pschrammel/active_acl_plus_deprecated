module ActiveAcl
  
  
end

# plugin dependency
require 'has_many_polymorphs'

require 'active_acl/db/active_record_adapter'
require 'active_acl/cache/no_cache_adapter'
require 'active_acl/options'
require 'active_acl/base'

require 'active_acl/privilege_const_set'
require 'active_acl/grant'

require 'active_acl/handler/object_handler'
require 'active_acl/handler/nested_set'
require 'active_acl/load_controller_actions'
require 'active_acl/acts_as_access_object'
require 'active_acl/acts_as_access_group'
require 'active_acl/load_files_from'


$:.unshift File.join(File.dirname(__FILE__),'../app/models/')

begin
['privilege','acl_section','privilege','requester_link','target_link',
'acl_section','requester_group_link','target_group_link','acl',
'controller_group','controller_action'].each do |model|
    require "active_acl/#{model}"
  end
rescue StandardError => e
  puts "[ERROR] ActiveAcl:  #{e.message}. Migrating?"
end

$:.shift
     