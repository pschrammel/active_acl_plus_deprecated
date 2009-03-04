# This module contains different second level cache implementations. The second
# level cache caches the instance cache of an access object between requests. 
# Cache adapter can be set with ActiveAcl::OPTIONS[:cache].
module ActiveAcl::Cache #:nodoc:
 
  # The default second level cache dummy implementation, not implementing any 
  # caching functionality at all.
  class NoCacheAdapter #:nodoc:
    def self.get(key)
      Rails.logger.debug 'ACTIVE_ACL::SECOND_LEVEL_CACHE::DISABLED::MISS ' + key.to_s
      nil
    end
      
    def self.set(key, value, ttl)
      Rails.logger.debug 'ACTIVE_ACL::SECOND_LEVEL_CACHE::DISABLED::SET ' + key.to_s + ' TO ' + value.inspect + ' TTL ' + ttl.to_s    
    end
    
    def self.delete(key)
      Rails.logger.debug 'ACTIVE_ACL::SECOND_LEVEL_CACHE::DISABLED::DELETE ' + key.to_s    
    end
  end
end