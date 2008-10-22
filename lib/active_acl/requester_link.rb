  class ActiveAcl::RequesterLink < ActiveRecord::Base
    set_table_name ActiveAcl::OPTIONS[:requester_links_table]
    
    belongs_to :acl
    belongs_to :aro, :polymorphic => true
           
    def self.reloadable? #:nodoc:
      return false
    end
  end