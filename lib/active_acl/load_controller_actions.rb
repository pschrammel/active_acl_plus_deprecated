
class ActionController::Base
  # Get the access object for the current action.
  def current_action
    ActiveAcl::CONTROLLERS[self.class.name][action_name]
  end 
  
  # alias method_added class method
  class << self
    alias :method_added_before_active_acl_controller_action_loading :method_added
  end
  
  # Overrides method_added, so the needed ActiveAcl::ControllerAction is loaded/created 
  # when the action gets added to the controller. 
  def self.method_added(action) #:nodoc:
    method_added_before_active_acl_controller_action_loading(action)
    ActiveAcl::CONTROLLERS[self.name] ||= {}

    if (public_instance_methods.include?(action.to_s))
      # if no loaded target found
      unless ActiveAcl::CONTROLLERS[self.name][action.to_s]
        # load it
        stripped_name = self.name.underscore.gsub(/_controller/, '')
        
        begin
          target = (ActiveAcl::CONTROLLERS[self.name][action.to_s] ||= ActiveAcl::ControllerAction.find_by_action_and_controller(action.to_s, stripped_name))
          unless target
            grp_name = stripped_name + ActiveAcl::OPTIONS[:controller_group_name_suffix]
            
            # find controller group
            cgroup = ActiveAcl::CONTROLLERS[self.name][:cgroup] ||= ActiveAcl::ControllerGroup.find_by_description(grp_name)
            
            unless cgroup
              #try to get main group
              main_group ||= (ActiveAcl::CONTROLLERS[ActiveAcl::OPTIONS[:controllers_group_name]] ||= ActiveAcl::ControllerGroup.find_by_description(ActiveAcl::OPTIONS[:controllers_group_name]))
           
              unless main_group
                # create main group
                base_group = ActiveAcl::ControllerGroup.root
                main_group = ActiveAcl::ControllerGroup.create(:description => ActiveAcl::OPTIONS[:controllers_group_name])
                # check if better_nested_set functionality is available
                if main_group.respond_to?(:move_to_child_of)
                  main_group.move_to_child_of base_group
                else
                  base_group.add_child main_group
                end
                
                ActiveAcl::CONTROLLERS[ActiveAcl::OPTIONS[:controllers_group_name]] = main_group
              end
              
              # create controller group
              cgroup = ActiveAcl::ControllerGroup.create(:description => grp_name)
              
              # check if better_nested_set functionality is available
              if cgroup.respond_to?(:move_to_child_of)
                cgroup.move_to_child_of main_group
              else
                main_group.add_child cgroup
              end
            end

            target = cgroup.controller_actions.create :action => action.to_s, :controller => stripped_name

            # save to collection
            ActiveAcl::CONTROLLERS[self.name][action.to_s] = target

          end # unless target fetched from db
                  
          # return target  
          return target
        rescue Exception => e
          Rails.logger.error("error loading target actions in controller #{self.name}: #{e.message}")
        end        
      end # unless target constant found
    end # if method is a action
  end # method_added
end