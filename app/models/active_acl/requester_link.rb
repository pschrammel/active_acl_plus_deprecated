module ActiveAcl
  class RequesterLink < ActiveRecord::Base
    set_table_name ActiveAcl::OPTIONS[:requester_links_table]
    
    belongs_to :acl, :class_name => "ActiveAcl::Acl"
    belongs_to :requester, :polymorphic => true
    
    def self.reloadable? #:nodoc:
      return false
    end
  end
end