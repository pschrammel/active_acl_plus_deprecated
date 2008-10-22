# This module contains different second level cache implementations. The second
# level cache caches the instance cache of an access object between requests. 
# Cache adapter can be set with ActiveAcl::OPTIONS[:cache].
module ActiveAcl::Cache
 
  # The default second level cache dummy implementation, not implementing any 
  # caching functionality at all.
  class NoCacheAdapter
    def self.get(key)
      RAILS_DEFAULT_LOGGER.debug 'GACL::SECOND_LEVEL_CACHE::DISABLED::MISS ' + key.to_s if RAILS_DEFAULT_LOGGER.debug?
      nil
    end
      
    def self.set(key, value, ttl)
      RAILS_DEFAULT_LOGGER.debug 'GACL::SECOND_LEVEL_CACHE::DISABLED::SET ' + key.to_s + ' TO ' + value.to_s + ' TTL ' + ttl.to_s if RAILS_DEFAULT_LOGGER.debug?    
    end
    
    def self.delete(key)
      RAILS_DEFAULT_LOGGER.debug 'GACL::SECOND_LEVEL_CACHE::DISABLED::DELETE ' + key.to_s if RAILS_DEFAULT_LOGGER.debug?    
    end
  end
end