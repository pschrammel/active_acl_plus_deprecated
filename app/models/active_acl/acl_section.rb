# Groups Acl model objects into different sections to provide better
# overview in the admin screens. Has no meaning in permission resolution.
module ActiveAcl
  class AclSection < ActiveRecord::Base
    set_table_name ActiveAcl::OPTIONS[:acl_sections_table]
    
    has_many :members, :class_name => 'ActiveAcl::Acl', :foreign_key => 'section_id'
    
    validates_presence_of :iname
    validates_uniqueness_of :iname
    
    # Make shure there are no associated acls before destroying a section
    def before_destroy #:nodoc:
      if members.empty?
        true
      else
        errors.add_to_base("Can't delete a section with associated ACLs")
        false
      end
    end
  end
end