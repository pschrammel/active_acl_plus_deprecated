module ActiveAcl
  unless const_defined?('OPTIONS')
    OPTIONS = {} 
  end
  
#  ActiveAcl::ACCESS_CLASSES = {}
#  ActiveAcl::GROUP_CLASSES = {}
  
  DEFAULT_OPTIONS = {
    :acl_sections_table => 'acl_sections',
    :acls_privileges_table => 'acls_privileges',
    :acls_table => 'acls',
    :privileges_table => 'privileges',
    :requester_links_table => 'requester_links',
    :target_links_table => 'target_links',
    :requester_group_links_table => 'requester_group_links',
    :target_group_links_table => 'target_group_links', 
    :controller_actions_table => 'controller_actions',
    :controller_groups_table => 'controller_groups',
  
    :controllers_group_name => 'unassigned_controller_actions',
    :controller_group_name_suffix => '_controller',
  
    :cache_privilege_timeout => 10,
  
    :db => ActiveAcl::DB::ActiveRecordAdapter,
    :cache => ActiveAcl::Cache::NoCacheAdapter,
    
    :default_selector_controller => 'selector',
    :default_selector_action => 'show_members',
    
    :default_group_selector_controller => 'selector',
    :default_group_selector_action => 'show_group_members'}
    
    # merge options
    OPTIONS.replace DEFAULT_OPTIONS.merge(OPTIONS)
end