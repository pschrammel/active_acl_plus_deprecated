# This model is used for grouping ActiveAcl::ControllerAction models. 
class ActiveAcl::ControllerGroup < ActiveRecord::Base
  set_table_name ActiveAcl::OPTIONS[:controller_groups_table]
  acts_as_nested_set
  has_many :controller_actions
  acts_as_access_group
 
  # Returns the instance representation in the admin screens. 
  def active_acl_description
    return description
  end

  # Returns the class representation in the admin screens.  
  def self.active_acl_description
    return 'ControllerGroup'
  end
  
  validates_presence_of 'description'
end