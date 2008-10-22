# This is a cache adapter for the second level cache
# using the memcache daemon (http://www.danga.com/memcached).
# Sets itself as the cache adapter if the source file is loaded so a simple
# require is enough to activate the memcache. Before using the memcache, make shure to set MemcacheAdapter.cache.
# 
# In environment.rb:
#   require 'active_acl/cache/memcache_adapter'
#   ActiveAcl::Cache::MemcacheAdapter.cache = MemCache.new('localhost:11211', :namespace => 'my_namespace')
#   
# Detailed instructions on how to set up the server can be found at http://dev.robotcoop.com/Libraries/memcache-client.
class ActiveAcl::Cache::MemcacheAdapter

  # returns the memcache server
  def self.cache
    @@cache
  end
  
  # sets the memcache server
  def self.cache= cache
    @@cache = cache
  end
  
  # get a value from the cache
  def self.get(key)
    value = @@cache.get(key)
    RAILS_DEFAULT_LOGGER.debug 'GACL::SECOND_LEVEL_CACHE::' + (value.nil? ? 'MISS ' : 'HIT ')+ key.to_s if RAILS_DEFAULT_LOGGER.debug?
    value
  end
  
  # set a value to the cache, specifying the time to live (ttl). 
  # Set ttl to 0 for unlimited.
  def self.set(key, value, ttl)
    @@cache.set(key, value, ttl)
    RAILS_DEFAULT_LOGGER.debug 'GACL::SECOND_LEVEL_CACHE::SET ' + key.to_s + ' TO ' + value.to_s + ' TTL ' + ttl.to_s if RAILS_DEFAULT_LOGGER.debug?    
  end
  
  # purge data from cache.
  def self.delete(key)
    @@cache.delete(key)
    RAILS_DEFAULT_LOGGER.debug 'GACL::SECOND_LEVEL_CACHE::DELETE ' + key.to_s if RAILS_DEFAULT_LOGGER.debug?    
  end
end

ActiveAcl::OPTIONS[:cache] = ActiveAcl::Cache::MemcacheAdapter