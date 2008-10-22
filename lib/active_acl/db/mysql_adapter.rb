require 'mysql'

# allow access to the real Mysql connection
class ActiveRecord::ConnectionAdapters::MysqlAdapter #:nodoc:
  attr_reader :connection #:nodoc:
end

# Uses the native MySQL connection to do privilege selects. Should be around 20 % faster than
# ActiveRecord adapter. Sets itself as the DB adapter if the source file is loaded, so requiring it
# is enough to get it activated.
class ActiveAcl::DB::MySQLAdapter

  # Execute sql query against the DB, returning an array of results.
  def self.query(sql)
    RAILS_DEFAULT_LOGGER.debug 'GACL::DB::EXECUTING QUERY ' + sql if RAILS_DEFAULT_LOGGER.debug?
    connection = ActiveRecord::Base.connection.connection
    connection.query_with_result = true
    
    result = connection.query(sql)
    rows = []
    result.each_hash do |hash|
      rows << hash
    end if result
    result.free
    rows
  end
end

ActiveAcl::OPTIONS[:db] = ActiveAcl::DB::MySQLAdapter