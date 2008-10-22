# This model is the "glue" :-). Every permission assignment uses an Acl 
# model object, assigns objects, groups and privileges and setting   
# 'allow' to "true" or "false" to grant or deny access.
class ActiveAcl::Acl < ActiveRecord::Base
  set_table_name ActiveAcl::OPTIONS[:acls_table]
  
  has_and_belongs_to_many :privileges, :uniq => true, :join_table => ActiveAcl::OPTIONS[:acls_privileges_table], :class_name => 'ActiveAcl::Privilege'
  
  has_many :target_links, :dependent => :delete_all
  has_many :requester_links, :dependent => :delete_all
  
  validates_uniqueness_of :note
  validates_presence_of :note
      
  belongs_to :section, :class_name => 'ActiveAcl::AclSection', :foreign_key => 'section_id'
  
  has_many :requester_group_links, :dependent => :delete_all
  has_many :target_group_links, :dependent => :delete_all
  
  has_many :requester_groups, :through => :requester_group_links, :source => :acl
  has_many :target_groups, :through => :target_group_links, :source => :acl
          
  def self.reloadable? #:nodoc:
    return false
  end
  
  # used as instance description in admin screen
  def active_acl_description
    if note
      if section
        '/' + section.description + '/' + note
      else
        return note
      end
    else
      return nil
    end
  end
end