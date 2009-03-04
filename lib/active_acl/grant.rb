module ActiveAcl
  module Acts 
    module Grant 
      # grant_permission!(Blog::DELETE,
      # :on => blog,
      # :section_name => 'blogging'
      # :acl_name => 'blogging_of_admins'  
      def grant_permission!(privilege,options={})
        section_name = options[:section_name] || 'generic'
        target = options[:on]
        iname = options[:acl_name] || "#{privilege.active_acl_description}"
        acl=nil
        ActiveAcl::Acl.transaction do
          section = ActiveAcl::AclSection.find_or_create_by_iname(section_name)
          section.save! if section.new_record?
          acl = ActiveAcl::Acl.create :section => section,:iname => iname
          acl.save!
          
          acl.privileges << privilege
          if ActiveAcl.is_access_group?(self.class) 
            acl.requester_groups << self
          else
            acl.requesters << self
          end
          if target
            if ActiveAcl.is_access_group?(target.class) 
              acl.target_groups << target
            else
              acl.targets << target
            end 
          end
          active_acl_clear_cache! if ActiveAcl.is_access_object?(self.class)
        end
        acl
      end
    end #module
  end
end
