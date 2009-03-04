class BaseTableSetup < ActiveRecord::Migration
  def self.up
    create_table ActiveAcl::OPTIONS[:acls_table] do |t|
        t.column :section_id,  :int
        t.column :iname,       :string,:null => false
        t.column :allow,       :boolean, :null => false, :default => true
        t.column :enabled,     :boolean, :null => false, :default => true
        t.column :description, :text, :null => true
        t.column :updated_at,  :datetime, :null => false
    end
    
    add_index ActiveAcl::OPTIONS[:acls_table], :enabled
    add_index ActiveAcl::OPTIONS[:acls_table], :section_id
    add_index ActiveAcl::OPTIONS[:acls_table], :updated_at
    add_index ActiveAcl::OPTIONS[:acls_table], :iname, :unique
    
        
    create_table ActiveAcl::OPTIONS[:acl_sections_table] do |t|
        t.column :iname,       :string, :null => false
        t.column :description, :text, :null => true
    end
    
    add_index ActiveAcl::OPTIONS[:acl_sections_table], :iname, :unique
        
    create_table ActiveAcl::OPTIONS[:privileges_table] do |t|
        t.column :section,        :string, :limit => 230, :null => false
        t.column :value,          :string, :limit => 230, :null => false
        t.column :description,    :string, :limit => 230, :null => true
    end
    
    add_index ActiveAcl::OPTIONS[:privileges_table], [:section, :value], :unique
        
    create_table ActiveAcl::OPTIONS[:acls_privileges_table], :id => false do |t|
        t.column :acl_id,         :int, :null => false
        t.column :privilege_id,  :int, :null => false
    end
    
    add_index ActiveAcl::OPTIONS[:acls_privileges_table], [:acl_id, :privilege_id], :unique
                                      
    create_table ActiveAcl::OPTIONS[:requester_links_table] do |t|
      t.column :acl_id, :int, :null => false
      t.column :requester_id, :int, :null => false
      t.column :requester_type, :string, :null => false
    end
    
    add_index ActiveAcl::OPTIONS[:requester_links_table], [:acl_id, :requester_id, :requester_type], :unique => true, :name => 'requester_links_join_index_1'
    add_index ActiveAcl::OPTIONS[:requester_links_table], [:requester_type, :requester_id], :name => 'requester_links_join_index_2'
    add_index ActiveAcl::OPTIONS[:requester_links_table], [:requester_id]

    create_table ActiveAcl::OPTIONS[:requester_group_links_table] do |t|
      t.column :acl_id, :int, :null => false
      t.column :requester_group_id, :int, :null => false
      t.column :requester_group_type, :string, :null => false
    end
    
    add_index ActiveAcl::OPTIONS[:requester_group_links_table], [:acl_id, :requester_group_id, :requester_group_type], :unique => true, :name => 'requester_group_links_join_index_1'
    add_index ActiveAcl::OPTIONS[:requester_group_links_table], [:requester_group_type, :requester_group_id], :name => 'requester_group_links_join_index2'
    
    create_table ActiveAcl::OPTIONS[:target_group_links_table] do |t|
      t.column :acl_id, :int, :null => false
      t.column :target_group_id, :int, :null => false
      t.column :target_group_type, :string, :null => false
    end
    
    add_index ActiveAcl::OPTIONS[:target_group_links_table], [:acl_id, :target_group_id, :target_group_type], :unique => true, :name => 'target_group_links_join_index_1'
    add_index ActiveAcl::OPTIONS[:target_group_links_table], [:target_group_type, :target_group_id], :name => 'target_group_links_join_index_2'
               
    create_table ActiveAcl::OPTIONS[:target_links_table] do |t|
      t.column :acl_id, :int, :null => false
      t.column :target_id, :int, :null => false
      t.column :target_type, :string, :null => false
    end
    
    add_index ActiveAcl::OPTIONS[:target_links_table], [:acl_id, :target_id, :target_type], :unique => true, :name => 'target_links_join_index_1'
    add_index ActiveAcl::OPTIONS[:target_links_table], [:target_type, :target_id], :name => 'target_links_join_index_2'
    add_index ActiveAcl::OPTIONS[:target_links_table], [:target_id]
    
    create_table ActiveAcl::OPTIONS[:controller_actions_table] do |t|
      t.column :controller, :string, :null => false
      t.column :action, :string, :null => false
      t.column :controller_group_id, :integer, :null => false
    end
    
    add_index ActiveAcl::OPTIONS[:controller_actions_table], [:controller, :action], :unique
  
    create_table ActiveAcl::OPTIONS[:controller_groups_table] do |t|
      t.column :description, :string, :null => false
      t.column :lft, :integer
      t.column :rgt, :integer
      t.column :parent_id, :integer     
    end
        
    add_index ActiveAcl::OPTIONS[:controller_groups_table], :description
    add_index ActiveAcl::OPTIONS[:controller_groups_table], :lft
    add_index ActiveAcl::OPTIONS[:controller_groups_table], :rgt
    add_index ActiveAcl::OPTIONS[:controller_groups_table], :parent_id
        
    # create root node
    execute("INSERT INTO #{ActiveAcl::OPTIONS[:controller_groups_table]}(description, lft, rgt) VALUES ('controllers', 1, 2)")      
  end
  
  def self.down
    drop_table ActiveAcl::OPTIONS[:acls_table]
    drop_table ActiveAcl::OPTIONS[:acl_sections_table]
    drop_table ActiveAcl::OPTIONS[:privileges_table]
    drop_table ActiveAcl::OPTIONS[:acls_privileges_table]
    drop_table ActiveAcl::OPTIONS[:requester_links_table]
    drop_table ActiveAcl::OPTIONS[:target_links_table]
    drop_table ActiveAcl::OPTIONS[:requester_group_links_table]
    drop_table ActiveAcl::OPTIONS[:target_group_links_table]
    drop_table ActiveAcl::OPTIONS[:controller_actions_table]
    drop_table ActiveAcl::OPTIONS[:controller_groups_table]  
  end
end