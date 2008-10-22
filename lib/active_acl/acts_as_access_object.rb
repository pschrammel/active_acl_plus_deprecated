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
        # habtm:: set to <code>true</code> if the grup is joined with a habtm association. If not specified, the plugin tries to guess if the association is has_and_belongs_to_many or belongs_to by creating the singular form of the :grouped_by option and comparing it to itself: If it matches, it assumes a belongs_to association. 
        def acts_as_access_object(options = {})
          configuration = {
            :controller => ActiveAcl::OPTIONS[:default_selector_controller],
            :action => ActiveAcl::OPTIONS[:default_selector_action]
          } 
          if options[:grouped_by]
            configuration[:group_class_name] = options[:grouped_by].to_s.classify
            configuration[:join_table] = [name.pluralize.underscore, configuration[:group_class_name].pluralize.underscore].sort.join('_')
            configuration[:foreign_key] = "#{name.underscore}_id"
            configuration[:association_foreign_key] = "#{configuration[:group_class_name].underscore}_id"
            configuration[:habtm] = (options[:grouped_by].to_s.demodulize.singularize != options[:grouped_by].to_s.demodulize)
          end
          
          configuration.update(options) if options.is_a?(Hash)
          
          ActiveAcl::ACCESS_CLASSES[self.name] = configuration
          
          has_many :requester_links, :as => :requester, :dependent => :delete_all, :class_name => 'ActiveAcl::RequesterLink'
          has_many :requester_acls, :through => :requester_links, :source => :acl, :class_name => 'ActiveAcl::Acl'
                            
          has_many :target_links, :as => :target, :dependent => :delete_all, :class_name => 'ActiveAcl::TargetLink'
          has_many :target_acls, :through => :target_links, :source => :acl, :class_name => 'ActiveAcl::Acl'
          
          include InstanceMethods
          extend SingletonMethods
          
          from_classes = ActiveAcl::ACCESS_CLASSES.keys.collect do |x| 
            x.split('::').join('/').underscore.pluralize.to_sym
          end
                                  
          ActiveAcl::Acl.instance_eval do
            has_many_polymorphs :requesters, {:from => from_classes, 
              :through => :"active_acl/requester_links", 
              :rename_individual_collections => true}
              
            has_many_polymorphs :targets, {:from => from_classes, 
              :through => :"active_acl/target_links", 
              :rename_individual_collections => true}              
          end
        
          self.module_eval do
            # checks if method is defined to not break tests
            unless instance_methods.include? "reload_before_gacl"
              alias :reload_before_gacl :reload
              
              # Redefines reload, making shure privilege caches are cleared on reload
              def reload
                clear_cached_permissions
                reload_before_gacl
              end
            end
          end

          # build ACL query strings once, so we don't need to do this on every request
          requester_groups_table = configuration[:group_class_name].constantize.table_name
          requester_group_type = configuration[:group_class_name].constantize.name
          requester_join_table = configuration[:join_table]
          requester_assoc_fk = configuration[:association_foreign_key]
          requester_fk = configuration[:foreign_key]
          requester_group_left = ActiveAcl::GROUP_CLASSES[configuration[:group_class_name]][:left_column].to_s
          requester_group_right = ActiveAcl::GROUP_CLASSES[configuration[:group_class_name]][:right_column].to_s
          requester_type = self.base_class.name

          # last join is necessary to weed out rules associated with targets groups
          query = <<-QUERY
            SELECT acls.id, acls.allow, privileges.id AS privilege_id FROM #{ActiveAcl::OPTIONS[:acls_table]} acls 
            LEFT JOIN #{ActiveAcl::OPTIONS[:acls_privileges_table]} acls_privileges ON acls_privileges.acl_id=acls.id 
            LEFT JOIN #{ActiveAcl::OPTIONS[:privileges_table]} privileges ON privileges.id = acls_privileges.privilege_id 
            LEFT JOIN #{ActiveAcl::OPTIONS[:requester_links_table]} r_links ON r_links.acl_id=acls.id
            LEFT JOIN #{ActiveAcl::OPTIONS[:requester_group_links_table]} r_g_links ON acls.id = r_g_links.acl_id AND r_g_links.requester_group_type = '#{requester_group_type}'
            LEFT JOIN #{requester_groups_table} r_groups ON r_g_links.requester_group_id = r_groups.id
            LEFT JOIN #{ActiveAcl::OPTIONS[:target_group_links_table]} t_g_links ON t_g_links.acl_id=acls.id
          QUERY
          
          acl_query_on_target = '' << query
          acl_query_prefetch = '' << query
                    
          # if there are no target groups, don't bother doing the join
          # else append type condition
          acl_query_on_target << " AND t_g_links.target_group_type = '%{target_group_type}' "
          acl_query_on_target << " LEFT JOIN #{ActiveAcl::OPTIONS[:target_links_table]} t_links ON t_links.acl_id=acls.id"
          acl_query_on_target << " LEFT JOIN %{target_groups_table} t_groups ON t_groups.id=t_g_links.target_group_id"
          
          acl_query_on_target << " WHERE acls.enabled = #{connection.quote(true)} AND (privileges.id = %{privilege_id}) "
          acl_query_prefetch << " WHERE acls.enabled = #{connection.quote(true)} "
            
          query = " AND (((r_links.requester_id=%{requester_id} ) AND (r_links.requester_type='#{requester_type}')) OR (r_g_links.requester_group_id IN "
          
          if configuration[:habtm]
            configuration[:query_group] = <<-QUERY
              (SELECT DISTINCT g2.id FROM #{requester_join_table} ml 
               LEFT JOIN #{requester_groups_table} g1 ON ml.#{requester_assoc_fk} = g1.id CROSS JOIN #{requester_groups_table} g2
               WHERE ml.#{requester_fk} = %{requester_id} AND (g2.#{requester_group_left} <= g1.#{requester_group_left} AND g2.#{requester_group_right} >= g1.#{requester_group_right})))
            QUERY
          else
            configuration[:query_group] = <<-QUERY
              (SELECT DISTINCT g2.id FROM #{requester_groups_table} g1 CROSS JOIN #{requester_groups_table} g2
               WHERE g1.id = %{requester_group_id} AND (g2.#{requester_group_left} <= g1.#{requester_group_left} AND g2.#{requester_group_right} >= g1.#{requester_group_right})))
            QUERY
          end
          
          query << configuration[:query_group]   
          query << " ) AND ( "
                	
          acl_query_on_target << query
          acl_query_prefetch << query
                             
          query = "(t_links.target_id=%{target_id} AND t_links.target_type = '%{target_type}' ) OR t_g_links.target_group_id IN %{target_group_query} "
                         
          acl_query_on_target << query
          acl_query_prefetch << '(t_g_links.acl_id IS NULL)) '
          
          # The ordering is always very tricky and makes all the difference in the world.
          # Order (CASE WHEN r_links.requester_type = \'Group\' THEN 1 ELSE 0 END) ASC
          # should put ACLs given to specific AROs ahead of any ACLs given to groups. 
          # This works well for exceptions to groups.     
          order_by_on_target = ['(CASE WHEN r_g_links.acl_id IS NULL THEN 0 ELSE 1 END) ASC ', "r_groups.#{requester_group_left} - r_groups.#{requester_group_right} ASC", 
                                  '(CASE WHEN t_g_links.acl_id IS NULL THEN 0 ELSE 1 END) ASC', 't_groups.%{target_group_left} - t_groups.%{target_group_right} ASC', 'acls.updated_at DESC']
          order_by_prefetch = ['privileges.id', '(CASE WHEN r_g_links.acl_id IS NULL THEN 0 ELSE 1 END) ASC ', "r_groups.#{requester_group_left} - r_groups.#{requester_group_right} ASC", 'acls.updated_at DESC']
          
          acl_query_on_target << 'ORDER BY ' + order_by_on_target.join(',') + ' LIMIT 1'
          acl_query_prefetch << 'ORDER BY ' + order_by_prefetch.join(',')
          
          # save query string to configuration
          configuration[:query_target] = acl_query_on_target.gsub(/\n+/, "\n")
          configuration[:query_simple] = acl_query_prefetch.gsub(/\n+/, "\n")                                           
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

          unless (privilege and (privilege.is_a?(Privilege)))
            # no need to check anything if privilege is not a Privilege
            return false
          end
          
          unless (target.nil? or (target.class.respond_to?(:base_class) and ActiveAcl::ACCESS_CLASSES.has_key?(target.class.base_class.name)))
            # no need to check anything if target is no Access Object
            return false
          end          
          
          query_id = [privilege.id, self.class.base_class.name, id, (target ? target.class.base_class.name : ''), (target ? target.id.to_s : '')].join('-')
          cache_id = 'gacl_instance-' + self.class.base_class.name + '-' + id.to_s
          cache = ActiveAcl::OPTIONS[:cache]
          
          # try to load instance cache from second level cache if not present
          @gacl_instance_cache = cache.get(cache_id) if @gacl_instance_cache.nil?
                    
          # try to get from instance cache
          if @gacl_instance_cache
            if not (value = @gacl_instance_cache[query_id]).nil?
              logger.debug 'GACL::INSTANCE_CACHE::' + (value ? 'GRANT ' : 'DENY ') + query_id if logger.debug?
              return value 
            elsif target.nil? and @gacl_instance_cache[:prefetch_done]
              # we didn't get a simple query from prefetched cache => cache miss
              logger.debug 'GACL::INSTANCE_CACHE::DENY ' + query_id if logger.debug?
              return false
            end
          end

          if value.nil? # still a cache miss?

            value = false
            
            r_config = ActiveAcl::ACCESS_CLASSES[self.class.base_class.name]
                                  
            if target
              qry = r_config[:query_target].clone
              
              t_config = ActiveAcl::ACCESS_CLASSES[target.class.base_class.name]
              
              qry.gsub!('%{target_group_type}', t_config[:group_class_name])
              qry.gsub!('%{target_groups_table}', t_config[:group_class_name].constantize.table_name)
              qry.gsub!('%{target_group_left}', ActiveAcl::GROUP_CLASSES[t_config[:group_class_name]][:left_column].to_s)
              qry.gsub!('%{target_group_right}', ActiveAcl::GROUP_CLASSES[t_config[:group_class_name]][:right_column].to_s)
              qry.gsub!('%{target_type}', target.class.base_class.name)
              qry.gsub!('%{target_id}', target.id.to_s)
              
              group_query = t_config[:query_group].clone
              group_query.gsub!('%{requester_id}', target.id.to_s)
              group_query.gsub!('%{requester_group_id}', target.send(t_config[:association_foreign_key]).to_s) unless t_config[:habtm]
              
              qry.gsub!('%{target_group_query}', group_query)
            else
              qry = r_config[:query_simple].clone
            end
                        
            # substitute variables
            qry.gsub!('%{requester_id}', self.id.to_s)
            qry.gsub!('%{privilege_id}', privilege.id.to_s)
            qry.gsub!('%{requester_group_id}', self.send(r_config[:association_foreign_key]).to_s) unless r_config[:habtm]        
            results = ActiveAcl::OPTIONS[:db].query(qry)
            
            if target.nil?
              # prefetch privileges
              privilegevalue = nil
              @gacl_instance_cache = {}
              
              results.each do |row|
                  if row['privilege_id'] != privilegevalue
                    privilegevalue = row['privilege_id']
                    c_id = [privilegevalue, self.class.base_class.name, id, '', ''].join('-')
                    @gacl_instance_cache[c_id] = ((row['allow'] == '1') or (row['allow'] == 't'))
                  end
              end
              
              value = @gacl_instance_cache[query_id]
              @gacl_instance_cache[:prefetch_done] = true
              
            elsif not results.empty?
              # normal gacl query without prefetching
              value = ((results[0]['allow'].to_s == '1') or (results[0]['allow'].to_s == 't'))
              @gacl_instance_cache ||= {} # create if not exists

              @gacl_instance_cache[query_id] = value
            end
 
            # nothing found, deny access
            @gacl_instance_cache[query_id] = value = false if value.nil?
 
            # save to second level cache
            cache.set(cache_id, @gacl_instance_cache, ActiveAcl::OPTIONS[:cache_privilege_timeout])
                                   
            logger.debug 'GACL::INSTANCE_CACHE::' + (value ? 'GRANT ' : 'DENY ') + query_id if logger.debug?

          end # cache miss
          return value
        end
        
        # override this to customize the description in the interface
        def active_acl_description
          to_s
        end
        
        # link to model selector
        def self.model_selector_link params
          AclsController.url_for(:action => :show_group_members, :clazz => self.class, *params)
        end
        
        # clears the permission caches (instance and memory cache)
        def clear_cached_permissions
          @gacl_instance_cache = nil
          ActiveAcl::OPTIONS[:cache].delete('gacl_instance-' + self.class.name + '-' + id.to_s)
        end

      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveAcl::Acts::AccessObject)