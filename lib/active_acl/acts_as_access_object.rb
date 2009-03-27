#require 'direct_handler'

module ActiveAcl #:nodoc:
  module Acts #:nodoc:
    module AccessObject #:nodoc:
      
      def self.included(base)    
        base.extend(ClassMethods)
      end
      
      module ClassMethods 
        
        # Extend self with access object capabilites. See README for details
        # on usage. Accepts the following options as a hash:
        # grouped_by:: name of the association acting as a group for access privilege
        # group_class_name:: class name of group class
        # join_table:: name of the join table
        # foreign_key:: foreign key of self in the join table
        # association_foreign_key:: foreign_key of the group class
        # habtm:: set to <code>true</code> if the grup is joined with a habtm association. 
        # If not specified, the plugin tries to guess if the association is 
        # has_and_belongs_to_many or belongs_to by creating the singular form of the 
        # :grouped_by option and comparing it to itself: If it matches, it assumes a belongs_to association. 
        def acts_as_access_object(options = {})
          
          handler=ObjectHandler.new(self,options) 
          
          ActiveAcl.register_object(self,handler)
          
          has_many :requester_links, :as => :requester, :dependent => :delete_all, :class_name => 'ActiveAcl::RequesterLink'
          has_many :requester_acls, :through => :requester_links, :source => :acl, :class_name => 'ActiveAcl::Acl'
          
          has_many :target_links, :as => :target, :dependent => :delete_all, :class_name => 'ActiveAcl::TargetLink'
          has_many :target_acls, :through => :target_links, :source => :acl, :class_name => 'ActiveAcl::Acl'
          
          include InstanceMethods
          extend SingletonMethods
          include ActiveAcl::Acts::Grant

          ActiveAcl::Acl.instance_eval do
            has_many_polymorphs :requesters, {:from => ActiveAcl.from_access_classes,
              :through => :"active_acl/requester_links", 
              :rename_individual_collections => true}
            
            has_many_polymorphs :targets, {:from => ActiveAcl.from_access_classes,
              :through => :"active_acl/target_links", 
              :rename_individual_collections => true}
          end

          self.module_eval do
            # checks if method is defined to not break tests
            unless instance_methods.include? "reload_before_active_acl"
              alias :reload_before_active_acl :reload
              
              # Redefines reload, making shure privilege caches are cleared on reload
              def reload(options={}) #:nodoc:
                active_acl_clear_cache!
                reload_before_active_acl(options)
              end
            end
          end
          
        end 
      end
      
      module SingletonMethods
        # class description in engine interface
        def active_acl_description
          return name
        end      
      end
      
      module InstanceMethods
        
        # checks if the user has a certain privilege, optionally on the given object.
        # Option :on defines the target object.  
        def has_privilege?(privilege, options = {})
          target = options[:on] #TODO: add error handling if not a hash
          # no need to check anything if privilege is not a Privilege
          raise "first Argument has to be a Privilege" unless privilege.is_a?(Privilege)
          # no need to check anything if target is no Access Object
          raise "target hast to be an AccessObject (#{target.class})" if target and !(target.class.respond_to?(:base_class) && ActiveAcl.is_access_object?(target.class))
          
          active_acl_handler.has_privilege?(self,privilege,target)
        end
        def active_acl_handler
          ActiveAcl.object_handler(self.class)
        end
        #returns a key value store
        def active_acl_instance_cache
          @active_acl_instance_cache ||= active_acl_handler.get_instance_cache(self)
        end
        #returns if the 2d acls are already cached
        def active_acl_cached_2d?
          !!active_acl_instance_cache[:prefetched_2d]
        end
        def active_acl_cached_2d!
          active_acl_instance_cache[:prefetched_2d]=true
        end
        
        def active_acl_clear_cache!
          @active_acl_instance_cache ={}         #clear the lokal cache
          active_acl_handler.delete_cached(self) #clear the 2 level cache
        end
        # override this to customize the description in the interface
        def active_acl_description
          to_s
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveAcl::Acts::AccessObject)