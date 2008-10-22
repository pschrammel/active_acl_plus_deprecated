  class ActiveAcl::RequesterGroupLink < ActiveRecord::Base
    set_table_name ActiveAcl::OPTIONS[:requester_group_links_table]
    
    belongs_to :acl
    belongs_to :requester_group, :polymorphic => true
           
    def self.reloadable? #:nodoc:
      return false
    end
  end