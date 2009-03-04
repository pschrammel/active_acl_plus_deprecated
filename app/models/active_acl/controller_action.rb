# This model is a DB representation of actions on an ActionController::Base
# controller and is grouped by ActiveAcl::ControllerGroup. 
class ActiveAcl::ControllerAction < ActiveRecord::Base
  set_table_name ActiveAcl::OPTIONS[:controller_actions_table]
  privilege_const_set('EXECUTE')

  belongs_to :controller_group, :class_name => 'ActiveAcl::ControllerGroup'
  acts_as_access_object :grouped_by => :"active_acl/controller_group"
  validates_presence_of :action, :controller, :controller_group
  
  # Returns the instance representation in the admin screens.
  def active_acl_description
    if action
      if controller
        return '/' + controller + '/' + action
      else
        return action
      end
    else
      return nil
    end
  end
  
  # Returns the class representation in the admin screens.
  def self.active_acl_description
    return 'Action'
  end
  

end