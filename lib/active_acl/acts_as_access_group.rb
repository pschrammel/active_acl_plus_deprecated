require 'active_record'

module ActiveAcl #:nodoc:
  module Acts #:nodoc:
    module AccessGroup #:nodoc:
      
      def self.included(base)    
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Extend self with access group capabilites. See README for details
        # on usage. Accepts the following options as a hash:
        # left_column:: name of the left column for nested set functionality, default :lft
        # right_column:: name of the right column for nested set functionality, default :rgt
        # Don't use 'left' and 'right' as column names - these are reserved words in most DBMS.
        def acts_as_access_group(options = {})
          configuration = {:left_column => :lft, :right_column => :rgt,
                           :controller => ActiveAcl::OPTIONS[:default_group_selector_controller],
                           :action => ActiveAcl::OPTIONS[:default_group_selector_action]}
          configuration.update(options) if options.is_a?(Hash)
          ActiveAcl::GROUP_CLASSES[self.name] = configuration
          
          from_classes = ActiveAcl::GROUP_CLASSES.keys.collect do |x| 
            x.split('::').join('/').underscore.pluralize.to_sym
          end
                        
          ActiveAcl::Acl.instance_eval do
            has_many_polymorphs :requester_groups, {:from => from_classes, 
              :through => :"active_acl/requester_group_links",
              :rename_individual_collections => true}

            has_many_polymorphs :target_groups, {:from => from_classes, 
              :through => :"active_acl/target_group_links",
              :rename_individual_collections => true}
          end
          
          include InstanceMethods
          extend SingletonMethods                         
          
         end
      end
      
      module SingletonMethods
        # class description in engine interface
        def active_acl_description
          name
        end
      end
      
      module InstanceMethods
        # override this to customize the description in the interface
        def active_acl_description
          to_s
        end              
      end
      
    end    
  end
end

ActiveRecord::Base.send(:include, ActiveAcl::Acts::AccessGroup)