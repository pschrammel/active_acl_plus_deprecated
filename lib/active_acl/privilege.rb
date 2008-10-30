# The basic "privilege" object, like Forum::VIEW might be the privilege to
# view a forum. Check the README for a detailed description on usage.
module ActiveAcl
  class Privilege < ActiveRecord::Base
    set_table_name ActiveAcl::OPTIONS[:privileges_table]
    
    has_and_belongs_to_many :acls, :uniq => true, :join_table => ActiveAcl::OPTIONS[:acls_privileges_table],:class_name => 'ActiveAcl::Acl'
    
    validates_presence_of :section, :value
    validates_uniqueness_of :value, :scope => :section
    
    # Returns the instance representation in the admin screens. 
    # Uses active_acl_description from class if present.     
    def active_acl_description
      begin
        section.constantize.active_acl_description
      rescue
        section
      end + '/' + value
    end
    
    def self.reloadable? #:nodoc:
      return false
    end
  end
end
