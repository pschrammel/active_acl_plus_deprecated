# This is a cache adapter for the second level cache
# using the memcache daemon (http://www.danga.com/memcached).
# Sets itself as the cache adapter if the source file is loaded so a simple
# require is enough to activate the memcache. Before using the memcache, make sure to set MemcacheAdapter.cache.
# 
# In environment.rb:
#   require 'active_acl/cache/memcache_adapter'
#   ActiveAcl::Cache::MemcacheAdapter.cache = MemCache.new('localhost:11211', :namespace => 'my_namespace')
# you can also set the time to leave:
#   ActiveAcl::OPTIONS[:cache_privilege_timeout]= time_in_seconds
#
# Detailed instructions on how to set up the server can be found at http://dev.robotcoop.com/Libraries/memcache-client.
class ActiveAcl::Cache::MemcacheAdapter

  # returns the memcache server
  def self.cache #:nodoc:
    @@cache
  end
  
  # sets the memcache server
  def self.cache=(cache) #:nodoc:
    @@cache = cache
  end
  
  # get a value from the cache
  def self.get(key) #:nodoc:
    value = @@cache.get(key)
    Rails.logger.debug 'GACL::SECOND_LEVEL_CACHE::' + (value.nil? ? 'MISS ' : 'HIT ')+ key.to_s
    value
  end
  
  # set a value to the cache, specifying the time to live (ttl). 
  # Set ttl to 0 for unlimited.
  def self.set(key, value, ttl) #:nodoc:
    @@cache.set(key, value, ttl)
    Rails.logger.debug 'GACL::SECOND_LEVEL_CACHE::SET ' + key.to_s + ' TO ' + value.inspect.to_s + ' TTL ' + ttl.to_s    
  end
  
  # purge data from cache.
  def self.delete(key) #:nodoc:
    @@cache.delete(key)
    Rails.logger.debug 'GACL::SECOND_LEVEL_CACHE::DELETE ' + key.to_s    
  end
end

ActiveAcl::OPTIONS[:cache] = ActiveAcl::Cache::MemcacheAdapter