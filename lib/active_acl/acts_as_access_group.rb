require 'active_record'

module ActiveAcl #:nodoc:
  module Acts #:nodoc:
    module AccessGroup #:nodoc:
      
      def self.included(base)    
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        # Extend self with access group capabilites.
        # Options can be: 
        # type:: is mandatory and is one of the group handler classes 
        # left_column:: for ActiveAcl::Acts::AccessGroup::NestedSet grouped objects
        # right_column:: for ActiveAcl::Acts::AccessGroup::NestedSet grouped objects
        
        def acts_as_access_group(options = {})
          type=options.delete(:type) || ActiveAcl::Acts::AccessGroup::NestedSet
          ActiveAcl.register_group(self,type.new(options))

          include ActiveAcl::Acts::Grant
          include InstanceMethods
          extend SingletonMethods                         
          
          ActiveAcl::Acl.instance_eval do
            has_many_polymorphs :requester_groups, {:from => ActiveAcl.from_group_classes,
              :through => :"active_acl/requester_group_links",
              :rename_individual_collections => true}
            
            has_many_polymorphs :target_groups, {:from => ActiveAcl.from_group_classes,
              :through => :"active_acl/target_group_links",
              :rename_individual_collections => true}
          end
          
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