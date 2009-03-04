module ActiveAcl
  class TargetGroupLink < ActiveRecord::Base
    set_table_name ActiveAcl::OPTIONS[:target_group_links_table]
    
    belongs_to :acl, :class_name => "ActiveAcl::Acl"
    belongs_to :target_group, :polymorphic => true
    
    def self.reloadable? #:nodoc:
      return false
    end
  end
end